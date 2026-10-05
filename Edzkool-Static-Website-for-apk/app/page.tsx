"use client";

import React, { useState } from "react";
import TopMarquee from "@/components/TopMarquee";
import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import PartnerTrustBar from "@/components/PartnerTrustBar";
import StatsBar from "@/components/StatsBar";
import CountryTabs from "@/components/CountryTabs";
import ServiceCards from "@/components/ServiceCards";
import ComparisonSection from "@/components/ComparisonSection";
import ApkDownloadSection from "@/components/ApkDownloadSection";
import LeadershipSection from "@/components/LeadershipSection";
import Testimonials from "@/components/Testimonials";
import FaqSection from "@/components/FaqSection";
import LeadModal from "@/components/LeadModal";
import Footer from "@/components/Footer";

export default function Home() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleOpenModal = () => setIsModalOpen(true);
  const handleCloseModal = () => setIsModalOpen(false);

  return (
    <main className="min-h-screen bg-white">
      {/* 1. Top Announcement Marquee Bar */}
      <TopMarquee />

      {/* 2. Sticky Navbar */}
      <Navbar onOpenModal={handleOpenModal} />

      {/* 3. Hero Section with /abroad.png & Interactive Form */}
      <HeroSection onOpenModal={handleOpenModal} />

      {/* 4. Partner & Accreditation Trust Bar */}
      <PartnerTrustBar />

      {/* 5. Key Metrics & Stats Bar */}
      <StatsBar />

      {/* 6. Destination Country Filterable Pill Tabs */}
      <CountryTabs onOpenModal={handleOpenModal} />

      {/* 7. End-to-End Service Cards with Local Vector SVGs */}
      <ServiceCards onOpenModal={handleOpenModal} />

      {/* 8. Comparison: Unverified Agents vs The Edzkool Way */}
      <ComparisonSection onOpenModal={handleOpenModal} />

      {/* 9. DOWNLOAD THE APK Section */}
      <ApkDownloadSection />

      {/* 10. Featured NMC-Approved Universities with Campus Images */}

      {/* 11. Leadership Message & Mission with /about.png */}
      <LeadershipSection />

      {/* 12. Student Testimonials with Student Avatars (/18.png, /20.png, /21.png) */}
      <Testimonials />

      {/* 13. FAQ Accordion */}
      <FaqSection />

      {/* 14. Footer */}
      <Footer />

      {/* Lead Booking Modal Dialog */}
      <LeadModal isOpen={isModalOpen} onClose={handleCloseModal} />

      {/* Floating Bottom Bar for Mobile */}
      <div className="fixed bottom-0 left-0 right-0 p-3 bg-white/95 backdrop-blur-md border-t border-gray-200 z-40 sm:hidden flex items-center justify-between shadow-lg">
        <div>
          <span className="text-xs font-black text-gray-900 block">Admissions Open 2026</span>
          <span className="text-[10px] text-[#103C82] font-bold">100% Free Counseling</span>
        </div>
        <button
          onClick={handleOpenModal}
          className="bg-[#103C82] text-white px-5 py-2.5 rounded-pill text-xs font-black shadow-md border-b-2 border-[#F58220]"
        >
          Book Free Call
        </button>
      </div>
    </main>
  );
}
