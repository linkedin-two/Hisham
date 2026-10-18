import React from "react";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-[#0B2A5B] text-[#C7D6EE]">
      <div className="max-w-[1200px] mx-auto px-6 pt-14 pb-9 flex flex-wrap gap-10 md:gap-16 justify-between">
        {/* Column 1: Brand Info */}
        <div className="flex-1 min-w-[280px] max-w-[380px] flex flex-col gap-4">
          <div className="bg-white rounded-2xl px-4 py-2.5 self-start">
            <img
              src="/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png"
              alt="EDZKOOL"
              className="h-9 w-auto object-contain block"
            />
          </div>
          <p className="text-[15px] leading-relaxed text-[#C7D6EE]">
            Online school, tuition for Grades 1 to 12, coding and language courses.
          </p>
        </div>

        {/* Column 2: Explore Navigation */}
        <div className="flex flex-col gap-2.5 text-[15px]">
          <div className="text-white font-bold mb-1">Explore</div>
          <Link href="/" className="text-[#C7D6EE] hover:text-white transition-colors">
            Home
          </Link>
          <Link href="/programs" className="text-[#C7D6EE] hover:text-white transition-colors">
            Programs
          </Link>
          <Link href="/certifications" className="text-[#C7D6EE] hover:text-white transition-colors">
            Certifications
          </Link>
          <Link href="/about" className="text-[#C7D6EE] hover:text-white transition-colors">
            About
          </Link>
          <Link href="/contact" className="text-[#C7D6EE] hover:text-white transition-colors">
            Contact
          </Link>
          <Link href="/#download-apk" className="text-[#FD9202] font-semibold hover:text-white transition-colors">
            Download App (APK)
          </Link>
        </div>

        {/* Column 3: Reach us */}
        <div className="flex flex-col gap-2.5 text-[15px]">
          <div className="text-white font-bold mb-1">Reach us</div>
          <a href="tel:+919876543210" className="text-[#C7D6EE] hover:text-white transition-colors">
            +91 98765 43210
          </a>
          <a href="mailto:care@edzkool.com" className="text-[#C7D6EE] hover:text-white transition-colors">
            care@edzkool.com
          </a>
          <span className="text-[#C7D6EE]">
            HSR Layout, Bengaluru, Karnataka, India
          </span>
          <div className="pt-2">
            <Link
              href="/contact"
              className="inline-block bg-[#FD9202] text-[#0B2A5B] font-bold text-xs px-4 py-2 rounded-full hover:brightness-105"
            >
              Book Free Demo
            </Link>
          </div>
        </div>
      </div>

      {/* Copyright Bar */}
      <div className="border-t border-[#1E3F76] px-6 py-5 text-center text-[13px] text-[#9DB4D8]">
        © 2026 EDZKOOL. All rights reserved.
      </div>
    </footer>
  );
}
