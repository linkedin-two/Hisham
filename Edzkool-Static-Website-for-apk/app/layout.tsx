import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "EDZKOOL | Online School and Tuition",
  description:
    "Live online classes for Grades 1 to 12, plus coding and language courses, taught by real teachers who know every child by name.",
  icons: {
    icon: "/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png",
    shortcut: "/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png",
    apple: "/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png",
  },
  keywords: [
    "EDZKOOL",
    "Online School",
    "Online Tuition Grades 1-12",
    "Coding and Robotics for kids",
    "Language Courses",
    "Certification Courses",
    "1-on-1 tutoring",
    "Live interactive classes"
  ],
  authors: [{ name: "EDZKOOL" }],
  metadataBase: new URL("https://edzkool.com"),
  openGraph: {
    title: "EDZKOOL | Online School and Tuition",
    description:
      "Live online classes for Grades 1 to 12, plus coding and language courses, taught by real teachers who know every child by name.",
    url: "https://edzkool.com",
    siteName: "EDZKOOL",
    images: [
      {
        url: "/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png",
        width: 800,
        height: 600,
      },
    ],
    locale: "en_IN",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className="antialiased selection:bg-[#144787] selection:text-white">
        {children}
      </body>
    </html>
  );
}
