-- Manual channel tests and customer campaigns. Apply after add_customer_engagement_reminders.sql.
alter table public.company_notification_templates drop constraint if exists company_notification_templates_event_type_check;
alter table public.company_notification_templates add constraint company_notification_templates_event_type_check check (event_type in ('visit_validated', 'mission_completed', 'reward_claimed', 'return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign'));
alter table public.communication_notification_outbox drop constraint if exists communication_notification_outbox_event_type_check;
alter table public.communication_notification_outbox add constraint communication_notification_outbox_event_type_check check (event_type in ('visit_validated', 'mission_completed', 'reward_claimed', 'return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign'));

create or replace function public.claim_communication_notifications()
returns table (
  outbox_id uuid, owner_id uuid, customer_id text, customer_name text,
  participant_id text, account_id text, event_type text, template_name text, template_language text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.communication_notification_outbox o
  set status = 'skipped', locked_at = null, last_error_code = 'invalid_phone_number'
  from public.customers customer, public.company_communication_integrations integration
  where o.owner_id = customer.owner_id and o.customer_id = customer.id
    and integration.owner_id = o.owner_id
    and o.status = 'pending' and (o.engagement_channel is null or o.engagement_channel = 'whatsapp')
    and not public.engagement_whatsapp_number_is_valid(customer.mobile, integration.phone_country_code)
    and exists (
      select 1 from public.customer_portal_communication_preferences pref
      join public.company_notification_templates template on template.owner_id = pref.owner_id
        and template.event_type = o.event_type and template.account_id = integration.whatsapp_account_id
        and template.enabled and template.template_status = 'APPROVED'
      where pref.owner_id = o.owner_id and pref.customer_id = o.customer_id
        and pref.channel = 'whatsapp'
        and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
        and pref.enabled and pref.revoked_at is null
    );

  update public.communication_notification_outbox o
  set status = 'skipped', locked_at = null, last_error_code = 'integration_or_template_disabled'
  where o.status = 'pending' and (o.engagement_channel is null or o.engagement_channel = 'whatsapp')
    and not exists (
      select 1 from public.company_communication_integrations i
      join public.company_notification_templates t on t.owner_id = i.owner_id and t.account_id = i.whatsapp_account_id
      join public.profiles p on p.id = i.owner_id and p.role = 'owner' and p.access = 'active'
      where i.owner_id = o.owner_id and i.zernio_api_key_ciphertext is not null and i.whatsapp_account_id is not null
        and t.event_type = o.event_type and t.enabled and t.template_status = 'APPROVED'
        and exists (select 1 from public.communication_schema_capabilities capability
          where capability.capability = 'whatsapp_named_template_variables_v1')
    );

  update public.communication_notification_outbox o
  set status = 'skipped', locked_at = null, last_error_code = 'consent_revoked'
  where o.status = 'pending' and (o.engagement_channel is null or o.engagement_channel = 'whatsapp')
    and not exists (
      select 1 from public.customer_portal_communication_preferences pref
      where pref.owner_id = o.owner_id and pref.customer_id = o.customer_id
        and pref.channel = 'whatsapp'
        and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
        and pref.enabled and pref.revoked_at is null
    );

  update public.communication_notification_outbox o
  set status = 'failed', locked_at = null, last_error_code = 'attempt_limit_reached'
  where o.status = 'processing' and o.locked_at < now() - interval '5 minutes' and o.attempt_count >= 5;

  return query
  with candidates as (
    select o.id
    from public.communication_notification_outbox o
    join public.customer_portal_communication_preferences pref
      on pref.owner_id = o.owner_id and pref.customer_id = o.customer_id
      and pref.channel = 'whatsapp'
      and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
      and pref.enabled and pref.revoked_at is null
    join public.company_communication_integrations integration on integration.owner_id = o.owner_id
    join public.company_notification_templates template
      on template.owner_id = o.owner_id and template.event_type = o.event_type
      and template.account_id = integration.whatsapp_account_id
      and template.enabled and template.template_status = 'APPROVED'
    join public.customers customer on customer.id = o.customer_id and customer.owner_id = o.owner_id
    join public.profiles profile on profile.id = o.owner_id and profile.role = 'owner' and profile.access = 'active'
    where (o.engagement_channel is null or o.engagement_channel = 'whatsapp')
      and (o.status = 'pending' or (o.status = 'processing' and o.locked_at < now() - interval '5 minutes'))
      and o.next_attempt_at <= now() and o.attempt_count < 5
      and integration.whatsapp_account_id is not null and integration.zernio_api_key_ciphertext is not null
      and public.engagement_whatsapp_number_is_valid(customer.mobile, integration.phone_country_code)
      and exists (select 1 from public.communication_schema_capabilities capability
        where capability.capability = 'whatsapp_named_template_variables_v1')
    order by o.created_at
    for update of o skip locked
    limit 5
  ), claimed as (
    update public.communication_notification_outbox o
    set status = 'processing', attempt_count = o.attempt_count + 1, locked_at = now()
    from candidates c where o.id = c.id
    returning o.*
  )
  select claimed.id, claimed.owner_id, claimed.customer_id, customer.name,
    case
      when length(phone.digits) between 12 and 15 and phone.digits like integration.phone_country_code || '%' then phone.digits
      when length(phone.digits) between 10 and 11 then integration.phone_country_code || phone.digits
      else null
    end,
    integration.whatsapp_account_id, claimed.event_type, template.template_name, template.template_language
  from claimed
  join public.customers customer on customer.id = claimed.customer_id and customer.owner_id = claimed.owner_id
  join public.company_communication_integrations integration on integration.owner_id = claimed.owner_id
  join public.company_notification_templates template on template.owner_id = claimed.owner_id and template.event_type = claimed.event_type
    and template.account_id = integration.whatsapp_account_id
  cross join lateral (select regexp_replace(coalesce(customer.mobile, ''), '[^0-9]+', '', 'g') as digits) phone;
end;
$$;
revoke all on function public.claim_communication_notifications() from public, anon, authenticated;
grant execute on function public.claim_communication_notifications() to service_role;

create or replace function public.authorize_communication_notification(
  outbox_id_input uuid,
  account_id_input text,
  template_name_input text,
  template_language_input text
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.communication_notification_outbox o
    join public.customer_portal_communication_preferences pref
      on pref.owner_id = o.owner_id and pref.customer_id = o.customer_id
      and pref.channel = 'whatsapp'
      and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
      and pref.enabled and pref.revoked_at is null
    join public.company_communication_integrations i
      on i.owner_id = o.owner_id and i.whatsapp_account_id = account_id_input and i.zernio_api_key_ciphertext is not null
    join public.company_notification_templates t
      on t.owner_id = o.owner_id and t.account_id = i.whatsapp_account_id and t.event_type = o.event_type
      and t.enabled and t.template_name = template_name_input and t.template_language = template_language_input
      and t.template_status = 'APPROVED'
    join public.customers customer on customer.id = o.customer_id and customer.owner_id = o.owner_id
    join public.profiles p on p.id = o.owner_id and p.role = 'owner' and p.access = 'active'
    where o.id = outbox_id_input and o.status = 'processing'
      and (o.engagement_channel is null or o.engagement_channel = 'whatsapp')
      and public.engagement_whatsapp_number_is_valid(customer.mobile, i.phone_country_code)
      and (o.event_type not in ('return_reminder', 'mission_reminder', 'reward_expiring')
        or public.customer_engagement_reminder_is_current(o.id))
      and exists (select 1 from public.communication_schema_capabilities capability
        where capability.capability = 'whatsapp_named_template_variables_v1')
  )
$$;
revoke all on function public.authorize_communication_notification(uuid, text, text, text) from public, anon, authenticated;
grant execute on function public.authorize_communication_notification(uuid, text, text, text) to service_role;

drop function if exists public.claim_customer_push_deliveries(integer);
create function public.claim_customer_push_deliveries(batch_limit integer default 50)
returns table (
  delivery_id uuid,
  owner_id uuid,
  customer_id text,
  customer_name text,
  business_name text,
  business_slug text,
  interface_language text,
  event_type text,
  endpoint_url text,
  p256dh_key text,
  auth_secret text,
  subscription_id uuid,
  card_unique_id uuid,
  message_title text,
  message_body text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.customer_push_subscriptions s
  set revoked_at = now(), endpoint_url = '', p256dh_key = '', auth_secret = '', updated_at = now()
  where s.revoked_at is null and s.expiration_time is not null and s.expiration_time <= now();

  update public.customer_push_notification_deliveries d
  set status = 'failed', locked_at = null, last_error_code = 'attempt_limit_reached'
  where d.status = 'processing' and d.locked_at < now() - interval '10 minutes' and d.attempt_count >= 5;

  update public.customer_push_notification_deliveries d
  set status = 'skipped', locked_at = null, last_error_code = 'outbox_channel_mismatch'
  from public.communication_notification_outbox o
  where o.id = d.outbox_id and d.status in ('pending', 'retry', 'processing')
    and o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign')
    and o.engagement_channel is distinct from 'push';

  update public.customer_push_notification_deliveries d
  set status = 'skipped', locked_at = null, last_error_code = 'consent_or_subscription_revoked'
  where d.status in ('pending', 'retry')
    and not exists (
      select 1
      from public.customer_push_subscription_links l
      join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
      join public.communication_notification_outbox o on o.id = d.outbox_id
      join public.customer_portal_communication_preferences pref
        on pref.owner_id = l.owner_id and pref.customer_id = l.customer_id
        and pref.channel = 'push'
        and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
        and pref.enabled and pref.revoked_at is null
      where l.subscription_id = d.subscription_id and l.owner_id = d.owner_id
        and l.customer_id = d.customer_id and l.card_unique_id = d.card_unique_id and l.revoked_at is null
    );

  return query
  with candidates as (
    select d.id
    from public.customer_push_notification_deliveries d
    join public.communication_notification_outbox o on o.id = d.outbox_id
    where (
        (d.status in ('pending', 'retry') and d.next_attempt_at <= now())
        or (d.status = 'processing' and d.locked_at < now() - interval '10 minutes')
      )
      and d.attempt_count < 5
      and (o.event_type not in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign')
        or o.engagement_channel = 'push')
      and exists (
        select 1
        from public.customer_push_subscription_links l
        join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
        join public.customer_portal_communication_preferences pref
          on pref.owner_id = l.owner_id and pref.customer_id = l.customer_id
          and pref.channel = 'push'
          and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
          and pref.enabled and pref.revoked_at is null
        where l.subscription_id = d.subscription_id and l.owner_id = d.owner_id
          and l.customer_id = d.customer_id and l.card_unique_id = d.card_unique_id and l.revoked_at is null
      )
    order by d.created_at
    for update of d skip locked
    limit greatest(1, least(coalesce(batch_limit, 50), 100))
  ), claimed as (
    update public.customer_push_notification_deliveries d
    set status = 'processing', locked_at = now(), attempt_count = d.attempt_count + 1
    from candidates c where d.id = c.id
    returning d.*
  )
  select c.id, c.owner_id, c.customer_id, cu.name, p.business_name, p.slug,
    p.interface_language, o.event_type, s.endpoint_url, s.p256dh_key, s.auth_secret,
    s.id, c.card_unique_id, c.message_title, c.message_body
  from claimed c
  join public.communication_notification_outbox o on o.id = c.outbox_id
  join public.customer_push_subscriptions s on s.id = c.subscription_id
  join public.customers cu on cu.id = c.customer_id and cu.owner_id = c.owner_id
  join public.profiles p on p.id = c.owner_id;
end;
$$;
revoke all on function public.claim_customer_push_deliveries(integer) from public, anon, authenticated;
grant execute on function public.claim_customer_push_deliveries(integer) to service_role;

create or replace function public.authorize_customer_push_delivery(delivery_id_input uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.customer_push_notification_deliveries d
    join public.communication_notification_outbox o on o.id = d.outbox_id
    join public.customer_push_subscription_links l
      on l.subscription_id = d.subscription_id and l.owner_id = d.owner_id
      and l.customer_id = d.customer_id and l.card_unique_id = d.card_unique_id and l.revoked_at is null
    join public.customer_push_subscriptions s on s.id = d.subscription_id and s.revoked_at is null
    join public.customer_portal_communication_preferences pref
      on pref.owner_id = d.owner_id and pref.customer_id = d.customer_id
      and pref.channel = 'push'
      and pref.category = case when o.event_type in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign') then 'marketing' else 'loyalty_updates' end
      and pref.enabled and pref.revoked_at is null
    where d.id = delivery_id_input and d.status = 'processing'
      and (o.event_type not in ('return_reminder', 'mission_reminder', 'reward_expiring', 'manual_campaign')
        or o.engagement_channel = 'push')
      and (o.event_type not in ('return_reminder', 'mission_reminder', 'reward_expiring')
        or public.customer_engagement_reminder_is_current(o.id))
  )
$$;
revoke all on function public.authorize_customer_push_delivery(uuid) from public, anon, authenticated;
grant execute on function public.authorize_customer_push_delivery(uuid) to service_role;

-- Manually initiated, consent-aware customer campaigns and channel tests.
create or replace function public.get_manual_campaign_recipients()
returns table (customer_id text, customer_name text, can_push boolean, can_whatsapp boolean)
language sql
security definer
stable
set search_path = public
as $$
  select c.id, c.name,
    exists (
      select 1 from public.customer_portal_communication_preferences pref
      join public.customer_push_subscription_links l on l.owner_id = pref.owner_id
        and l.customer_id = pref.customer_id and l.revoked_at is null
      join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
        and (s.expiration_time is null or s.expiration_time > now())
      join public.issued_cards ic on ic.unique_id = l.card_unique_id and ic.owner_id = l.owner_id
        and ic.customer_id = l.customer_id and ic.status = 'Active'
      where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'push'
        and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
    ),
    exists (
      select 1 from public.customer_portal_communication_preferences pref
      join public.company_communication_integrations i on i.owner_id = pref.owner_id
        and i.whatsapp_account_id is not null and i.zernio_api_key_ciphertext is not null
      join public.company_notification_templates t on t.owner_id = pref.owner_id
        and t.event_type = 'manual_campaign' and t.account_id = i.whatsapp_account_id
        and t.enabled and t.template_status = 'APPROVED'
      where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'whatsapp'
        and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
        and public.engagement_whatsapp_number_is_valid(c.mobile, i.phone_country_code)
    )
  from public.customers c
  join public.profiles p on p.id = c.owner_id and p.id = auth.uid()
    and p.role = 'owner' and p.access = 'active'
  where c.status = 'Active'
    and (exists (
      select 1 from public.customer_portal_communication_preferences pref
      join public.customer_push_subscription_links l on l.owner_id = pref.owner_id
        and l.customer_id = pref.customer_id and l.revoked_at is null
      join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
        and (s.expiration_time is null or s.expiration_time > now())
      join public.issued_cards ic on ic.unique_id = l.card_unique_id and ic.owner_id = l.owner_id
        and ic.customer_id = l.customer_id and ic.status = 'Active'
      where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'push'
        and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
    ) or exists (
      select 1 from public.customer_portal_communication_preferences pref
      join public.company_communication_integrations i on i.owner_id = pref.owner_id
        and i.whatsapp_account_id is not null and i.zernio_api_key_ciphertext is not null
      join public.company_notification_templates t on t.owner_id = pref.owner_id
        and t.event_type = 'manual_campaign' and t.account_id = i.whatsapp_account_id
        and t.enabled and t.template_status = 'APPROVED'
      where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'whatsapp'
        and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
        and public.engagement_whatsapp_number_is_valid(c.mobile, i.phone_country_code)
    ))
  order by c.name;
$$;
revoke all on function public.get_manual_campaign_recipients() from public, anon;
grant execute on function public.get_manual_campaign_recipients() to authenticated;

create or replace function public.queue_manual_customer_campaign(
  channel_input text,
  title_input text,
  body_input text,
  test_customer_id_input text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  owner_id_value uuid := auth.uid();
  campaign_key uuid := gen_random_uuid();
  channel_value text;
  channel_values text[];
  recipient record;
  queued_count integer := 0;
  outbox_id_value uuid;
begin
  if owner_id_value is null or not exists (
    select 1 from public.profiles p where p.id = owner_id_value and p.role = 'owner' and p.access = 'active'
  ) then raise exception 'Active company owner required.'; end if;
  if channel_input not in ('push', 'whatsapp', 'both') then raise exception 'Choose a supported channel.'; end if;
  if channel_input in ('push', 'both') and (
    length(trim(coalesce(title_input, ''))) not between 1 and 70
    or length(trim(coalesce(body_input, ''))) not between 1 and 220
  ) then
    raise exception 'Enter a title of up to 70 characters and a message of up to 220 characters.';
  end if;
  if channel_input in ('whatsapp', 'both') and not exists (
    select 1 from public.company_communication_integrations i
    join public.company_notification_templates t on t.owner_id = i.owner_id
      and t.event_type = 'manual_campaign' and t.account_id = i.whatsapp_account_id
      and t.enabled and t.template_status = 'APPROVED'
    where i.owner_id = owner_id_value and i.whatsapp_account_id is not null
      and i.zernio_api_key_ciphertext is not null
  ) then raise exception 'Configure an approved WhatsApp campaign template first.'; end if;

  channel_values := case when channel_input = 'both' then array['push','whatsapp'] else array[channel_input] end;
  foreach channel_value in array channel_values loop
    for recipient in
      select c.id as customer_id, ic.id as card_id, ic.unique_id as card_unique_id
      from public.customers c
      join public.profiles p on p.id = c.owner_id and p.id = owner_id_value
        and p.role = 'owner' and p.access = 'active'
      left join lateral (
        select active_card.id, active_card.unique_id, active_card.created_at
        from public.issued_cards active_card
        where active_card.owner_id = c.owner_id and active_card.customer_id = c.id
          and active_card.status = 'Active'
          and (channel_value <> 'push' or exists (
            select 1 from public.customer_push_subscription_links active_link
            join public.customer_push_subscriptions active_subscription
              on active_subscription.id = active_link.subscription_id and active_subscription.revoked_at is null
              and (active_subscription.expiration_time is null or active_subscription.expiration_time > now())
            where active_link.owner_id = active_card.owner_id and active_link.customer_id = active_card.customer_id
              and active_link.card_unique_id = active_card.unique_id and active_link.revoked_at is null
          ))
        order by active_card.created_at desc
        limit 1
      ) ic on true
      where c.owner_id = owner_id_value and c.status = 'Active'
        and (test_customer_id_input is null or c.id = test_customer_id_input)
        and (
          (channel_value = 'push' and exists (
            select 1 from public.customer_portal_communication_preferences pref
            join public.customer_push_subscription_links l on l.owner_id = pref.owner_id
              and l.customer_id = pref.customer_id and l.card_unique_id = ic.unique_id and l.revoked_at is null
            join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
              and (s.expiration_time is null or s.expiration_time > now())
            where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'push'
              and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
          ))
          or (channel_value = 'whatsapp' and exists (
            select 1 from public.customer_portal_communication_preferences pref
            join public.company_communication_integrations i on i.owner_id = pref.owner_id
              and i.whatsapp_account_id is not null and i.zernio_api_key_ciphertext is not null
            join public.company_notification_templates t on t.owner_id = pref.owner_id
              and t.event_type = 'manual_campaign' and t.account_id = i.whatsapp_account_id
              and t.enabled and t.template_status = 'APPROVED'
            where pref.owner_id = c.owner_id and pref.customer_id = c.id and pref.channel = 'whatsapp'
              and pref.category = 'marketing' and pref.enabled and pref.revoked_at is null
              and public.engagement_whatsapp_number_is_valid(c.mobile, i.phone_country_code)
          ))
        )
      order by c.id, ic.created_at desc
    loop
      if exists (select 1 from public.communication_notification_outbox o
        where o.owner_id = owner_id_value and o.event_key = 'manual_campaign:' || campaign_key::text || ':' || channel_value || ':' || recipient.customer_id) then
        continue;
      end if;
      insert into public.communication_notification_outbox(
        owner_id, customer_id, event_type, event_key, engagement_channel,
        card_id, message_title, message_body
      ) values (
        owner_id_value, recipient.customer_id, 'manual_campaign',
        'manual_campaign:' || campaign_key::text || ':' || channel_value || ':' || recipient.customer_id,
        channel_value, recipient.card_id,
        case when channel_value = 'push' then trim(title_input) else null end,
        case when channel_value = 'push' then trim(body_input) else null end
      ) returning id into outbox_id_value;

      if channel_value = 'push' then
        insert into public.customer_push_notification_deliveries(
          outbox_id, subscription_id, owner_id, customer_id, card_unique_id, message_title, message_body
        )
        select outbox_id_value, l.subscription_id, owner_id_value, recipient.customer_id,
          l.card_unique_id, left(trim(title_input),70), left(trim(body_input),220)
        from public.customer_push_subscription_links l
        join public.customer_push_subscriptions s on s.id = l.subscription_id and s.revoked_at is null
          and (s.expiration_time is null or s.expiration_time > now())
        join public.customer_portal_communication_preferences pref on pref.owner_id = l.owner_id
          and pref.customer_id = l.customer_id and pref.channel = 'push' and pref.category = 'marketing'
          and pref.enabled and pref.revoked_at is null
        where l.owner_id = owner_id_value and l.customer_id = recipient.customer_id
          and l.card_unique_id = recipient.card_unique_id and l.revoked_at is null
        on conflict do nothing;
      end if;
      queued_count := queued_count + 1;
    end loop;
  end loop;
  return jsonb_build_object('queued', queued_count, 'campaignId', campaign_key);
end;
$$;
revoke all on function public.queue_manual_customer_campaign(text, text, text, text) from public, anon;
grant execute on function public.queue_manual_customer_campaign(text, text, text, text) to authenticated;
