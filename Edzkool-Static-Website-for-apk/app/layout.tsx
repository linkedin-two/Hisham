import type { Metadata } from "next";
import "./globals.css";
import JsonLdSchema from "@/components/JsonLdSchema";

export const metadata: Metadata = {
  title: "Edzkool, online, school: one to one tuition, coaching classes, English, IELTS, Tuition 1-10, Coding Classes",
  description:
    "Edzkool offers premium online 1-to-1 tuition, coaching classes, English, IELTS, tuition for grades 1-10, and coding classes. Empowering students with personalized learning.",
  icons: {
    icon: "/Hisham/logo.png",
    shortcut: "/Hisham/logo.png",
    apple: "/Hisham/logo.png",
  },
  keywords: [
    "Edzkool",
    "online school",
    "one to one tuition",
    "coaching classes",
    "English",
    "IELTS",
    "Tuition 1-10",
    "Coding Classes",
    "Personalized Learning",
    "Online Tutoring"
  ],
  authors: [{ name: "Edzkool" }],
  metadataBase: new URL("https://edzkool.com"),
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: "Edzkool, online, school: one to one tuition, coaching classes, English, IELTS, Tuition 1-10, Coding Classes",
    description: "Edzkool offers premium online 1-to-1 tuition, coaching classes, English, IELTS, tuition for grades 1-10, and coding classes.",
    url: "https://edzkool.com",
    siteName: "Edzkool",
    images: [
      {
        url: "/Hisham/logo.png",
        width: 800,
        height: 600,
      },
    ],
    locale: "en_IN",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Edzkool, online, school: one to one tuition, coaching classes",
    description: "Premium online 1-to-1 tuition, coaching classes, English, IELTS, Tuition 1-10, and coding classes with Edzkool.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <head>
        <JsonLdSchema />
      </head>
      <body className="antialiased selection:bg-[#103C82] selection:text-white">
        {children}
      </body>
    </html>
  );
}
