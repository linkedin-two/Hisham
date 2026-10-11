"use client";

import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";

export default function TopMarquee() {
  const marqueeItems = [
    `🎓 Admissions Open 2026: MBBS Abroad & 1-on-1 Coaching`,
    `📞 Call: ${EDZKOOL_DATA.company.phone} | ✉️ info@edzkool.com`,
    `⭐ ${EDZKOOL_DATA.company.studentsMentored} Students Empowered Globally`,
    `🚀 100% University Admission & Visa Assistance`,
    `⚡ Free 1-on-1 Trial Class Available | Enroll Now`,
    `🌍 Top Programs: MBBS Abroad, IELTS Prep & Academic Tuition`,
  ];

  return (
    <div className="bg-[#0B254E] text-white text-xs md:text-sm font-medium py-2 overflow-hidden border-b border-[#143B73]">
      <div className="flex animate-marquee">
        {marqueeItems.map((item, idx) => (
          <span key={idx} className="flex items-center space-x-2 mr-12 shrink-0">
            <span>{item}</span>
            <span className="text-[#F58220] font-black">|</span>
          </span>
        ))}
      </div>
    </div>
  );
}
