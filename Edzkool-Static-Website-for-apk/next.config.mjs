/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ["edzkool.com"],
  },
  async headers() {
    return [
      {
        source: "/edzkool-app.apk",
        headers: [
          {
            key: "Content-Type",
            value: "application/vnd.android.package-archive",
          },
          {
            key: "Content-Disposition",
            value: 'attachment; filename="Edzkool_Student_App.apk"',
          },
        ],
      },
      {
        source: "/:path*.apk",
        headers: [
          {
            key: "Content-Type",
            value: "application/vnd.android.package-archive",
          },
          {
            key: "Content-Disposition",
            value: 'attachment; filename="Edzkool_Student_App.apk"',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
