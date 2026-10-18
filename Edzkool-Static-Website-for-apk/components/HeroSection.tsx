import React from "react";
import Link from "next/link";

export default function HeroSection() {
  return (
    <section className="bg-gradient-to-b from-[#F4F8FE] to-white">
      <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-10 items-center">
        {/* Left Column */}
        <div className="flex-1 min-w-[320px] md:min-w-[440px] flex flex-col gap-6">
          <div className="inline-flex self-start bg-[#FFF1DB] text-[#8A4B00] text-[13px] font-bold tracking-wider uppercase px-3.5 py-2 rounded-full">
            Online school · Tuition · Skills
          </div>

          <h1 className="font-serif text-4xl sm:text-5xl lg:text-[60px] leading-[1.05] font-bold text-[#0B2A5B] tracking-tight">
            Learning that feels{" "}
            <span className="text-[#144787] shadow-[inset_0_-0.28em_0_#FFD08A]">
              cool
            </span>
            , and works.
          </h1>

          <p className="text-lg md:text-[19px] leading-relaxed text-[#44546F] max-w-[540px]">
            Live online classes for Grades 1 to 12, plus coding and language courses,
            taught by real teachers who know every child by name.
          </p>

          <div className="flex flex-wrap gap-3.5 pt-1.5">
            <Link
              href="/contact"
              className="bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-7 py-4 rounded-full inline-block transition-transform transform hover:-translate-y-0.5 shadow-sm"
            >
              Book a free demo class
            </Link>
            <Link
              href="/programs"
              className="bg-white hover:bg-gray-50 text-[#144787] font-bold text-base px-6 py-3.5 rounded-full border-2 border-[#144787] inline-block transition-colors"
            >
              Explore programs
            </Link>
          </div>

          <div className="flex flex-wrap gap-x-6 gap-y-2.5 pt-2 text-sm font-semibold text-[#44546F]">
            <span className="flex items-center gap-1.5">
              <span className="text-[#FD9202] font-black">✓</span> Live, interactive classes
            </span>
            <span className="flex items-center gap-1.5">
              <span className="text-[#FD9202] font-black">✓</span> Grades 1 to 12
            </span>
            <span className="flex items-center gap-1.5">
              <span className="text-[#FD9202] font-black">✓</span> Free demo, no commitment
            </span>
          </div>
        </div>

        {/* Right Column: Hero Illustration */}
        <div className="flex-1 min-w-[300px] md:min-w-[400px] flex justify-center items-center">
          <img
            src="/edzkool_new_images/home-header.png"
            alt="EDZKOOL Learning that feels cool and works"
            className="w-full max-w-[520px] h-auto object-contain block drop-shadow-sm rounded-2xl"
          />
        </div>
      </div>
    </section>
  );
}
