import { createECDH } from 'node:crypto';

const ecdh = createECDH('prime256v1');
const publicKey = ecdh.generateKeys();
const privateKey = ecdh.getPrivateKey();
const toBase64Url = value => Buffer.from(value).toString('base64url');

process.stdout.write([
  `VITE_WEB_PUSH_PUBLIC_KEY=${toBase64Url(publicKey)}`,
  `WEB_PUSH_PUBLIC_KEY=${toBase64Url(publicKey)}`,
  `WEB_PUSH_PRIVATE_KEY=${toBase64Url(privateKey)}`,
  '# Replace with your own contact address, e.g. mailto:voce@suaempresa.com.br',
  'WEB_PUSH_SUBJECT=mailto:admin@localhost',
].join('\n') + '\n');
