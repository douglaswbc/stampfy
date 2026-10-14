import { getBusinessSiteDomain } from './businessSiteDomain';

const normalizeOrigin = (value: string) => value.trim().replace(/\/+$/, "");

const clean = (value: string | undefined) => value?.trim() || undefined;

const configuredAppUrl = clean(import.meta.env.VITE_APP_URL);
const configuredSupportEmail = clean(import.meta.env.VITE_SUPPORT_EMAIL);
const configuredSalesEmail = clean(import.meta.env.VITE_SALES_EMAIL);
const configuredAppName = clean(import.meta.env.VITE_APP_NAME);
const configuredAppDescription = clean(import.meta.env.VITE_APP_DESCRIPTION);
const demoWorkspaceFlag = import.meta.env.VITE_ENABLE_DEMO_WORKSPACE?.trim().toLowerCase();

export const APP_NAME = configuredAppName || "Stampfy";

export const APP_DESCRIPTION =
  configuredAppDescription ||
  `Crie campanhas de fidelidade com cartões digitais e recompensas. Acompanhe visitas, clientes e resgates do seu comércio com o ${APP_NAME}.`;

/**
 * Canonical public origin of the deployment. Falls back to the current
 * window origin so preview and self-hosted deployments resolve correctly.
 */
export const APP_ORIGIN = normalizeOrigin(
  configuredAppUrl ||
    (typeof window !== "undefined" ? window.location.origin : "") ||
    "http://localhost:3000"
);

export const BUSINESS_SITE_DOMAIN = getBusinessSiteDomain(APP_ORIGIN);

export const SUPPORT_EMAIL = configuredSupportEmail || "";
export const SALES_EMAIL = configuredSalesEmail || configuredSupportEmail || "";

export const DEMO_WORKSPACE_ENABLED = import.meta.env.DEV
  ? demoWorkspaceFlag !== "false"
  : demoWorkspaceFlag === "true";

export const buildAppUrl = (path = "/") => {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  return `${APP_ORIGIN}${normalizedPath}`;
};

/** Absolute URL to a static asset shipped in `public/`. */
export const buildAssetUrl = (path: string) => {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  return `${APP_ORIGIN}${normalizedPath}`;
};