"use client";

import React from "react";
import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import StatsBar from "@/components/StatsBar";
import InterestPicker from "@/components/InterestPicker";
import ClassroomFeature from "@/components/ClassroomFeature";
import HowItWorks from "@/components/HowItWorks";
import Testimonials from "@/components/Testimonials";
import ApkDownloadSection from "@/components/ApkDownloadSection";
import CtaBand from "@/components/CtaBand";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen bg-white">
      {/* 1. Header with announcement bar & nav */}
      <Navbar />

      {/* 2. Hero Section */}
      <HeroSection />

      {/* 3. Stats Band */}
      <StatsBar />

      {/* 4. Child Interest Matcher Picker */}
      <InterestPicker />

      {/* 5. Inside a Class Feature Section */}
      <ClassroomFeature />

      {/* 6. How it works 4-step onboarding */}
      <HowItWorks />

      {/* 7. Parent Testimonials */}
      <Testimonials />

      {/* 8. Download the APK Section */}
      <ApkDownloadSection />

      {/* 9. Call To Action Pre-Footer Band */}
      <CtaBand />

      {/* 10. Global Footer */}
      <Footer />
    </main>
  );
}
