/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  basePath: "/Hisham",
  reactStrictMode: true,
  images: {
    domains: ["edzkool.com"],
    unoptimized: true,
  },
};

export default nextConfig;
