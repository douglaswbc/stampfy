/**
 * Canonical SEO configuration, shared by the Vite plugin and the sitemap script.
 *
 * Every value is derived from environment variables so that a deployment — or a
 * white-label reseller rebranding this project — controls canonical URLs, social
 * previews and structured data without editing source files.
 */

const clean = (value) => (typeof value === "string" ? value.trim() : "");

const stripTrailingSlash = (value) => value.replace(/\/+$/, "");

export const readSeoConfig = (env = process.env) => {
  const appUrl = stripTrailingSlash(
    clean(env.VITE_APP_URL) || clean(env.SITE_ORIGIN) || "http://localhost:3000"
  );

  const appName = clean(env.VITE_APP_NAME) || "Stampfy";

  const defaultDescription = `Crie campanhas de fidelidade com cartões digitais e recompensas. Acompanhe visitas, clientes e resgates do seu comércio com o ${appName}.`;

  const description = clean(env.VITE_APP_DESCRIPTION) || defaultDescription;

  const socialImage = clean(env.VITE_SOCIAL_IMAGE) || `${appUrl}/social-preview-v2.jpg`;

  return { appUrl, appName, description, socialImage };
};

/** `__TOKEN__` placeholders used in `index.html`. */
export const buildSeoTokens = (config) => ({
  __APP_URL__: config.appUrl,
  __APP_URL_SLASH__: `${config.appUrl}/`,
  __APP_NAME__: config.appName,
  __APP_DESCRIPTION__: config.description,
  __SOCIAL_IMAGE__: config.socialImage,
});

const escapeAttribute = (value) =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

/** JSON-LD lives inside a <script> block, so quotes/backslashes must be escaped. */
const escapeJson = (value) => value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

const TOKEN_PATTERN = /__(APP_URL_SLASH|APP_URL|APP_NAME|APP_DESCRIPTION|SOCIAL_IMAGE)__/g;

/**
 * Vite plugin that substitutes SEO tokens in `index.html` during both
 * `vite dev` and `vite build`. Non-destructive: the source file is untouched.
 *
 * @param {Record<string, string | undefined>} [env]
 * @returns {import("vite").Plugin}
 */
export const seoTokensPlugin = (env = process.env) => {
  let config = readSeoConfig(env);

  return {
    name: "stampfy-seo-tokens",
    configResolved() {
      // Vite loads .env files into import.meta.env, not process.env.
      // Re-read with VITE_ vars already resolved so dev and build agree.
      config = readSeoConfig({
        ...env,
        VITE_APP_URL: env.VITE_APP_URL || process.env.VITE_APP_URL,
        VITE_APP_NAME: env.VITE_APP_NAME || process.env.VITE_APP_NAME,
        VITE_APP_DESCRIPTION: env.VITE_APP_DESCRIPTION || process.env.VITE_APP_DESCRIPTION,
        VITE_SOCIAL_IMAGE: env.VITE_SOCIAL_IMAGE || process.env.VITE_SOCIAL_IMAGE,
      });
    },
    transformIndexHtml: {
      order: "pre",
      handler(html) {
        const tokens = buildSeoTokens(config);
        return html.replace(TOKEN_PATTERN, (match, key) => {
          const value = tokens[`__${key}__`] ?? "";
          return key === "APP_DESCRIPTION" ? escapeJson(value) : escapeAttribute(value);
        });
      },
    },
  };
};