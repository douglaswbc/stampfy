const parseHostname = (appUrl?: string | null) => {
  const configured = appUrl?.trim();
  if (!configured) return '';
  try {
    const url = new URL(configured.includes('://') ? configured : `https://${configured}`);
    return url.hostname.toLowerCase().replace(/^www\./, '');
  } catch {
    return '';
  }
};

export const getBusinessSiteDomain = (appUrl?: string | null) => parseHostname(appUrl) || 'localhost';

export const getFallbackBusinessSiteSlug = (host: string, appUrl?: string | null) => {
  const domain = getBusinessSiteDomain(appUrl);
  const suffix = `.${domain}`;
  if (!host.endsWith(suffix)) return '';
  const slug = host.slice(0, -suffix.length);
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) ? slug : '';
};

export const isBusinessPlatformHost = (host: string, appUrl?: string | null) => {
  const appHost = parseHostname(appUrl);
  const businessSiteDomain = getBusinessSiteDomain(appUrl);
  return host === appHost || host === businessSiteDomain || host === `www.${businessSiteDomain}` || host.endsWith('.vercel.app');
};