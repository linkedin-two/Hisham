"use client";

import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";

export default function TopMarquee() {
  const marqueeItems = [
    `🎓 Enroll Now for Grades 1-10 | Premium 1-on-1 Online Tuition`,
    `🚀 ${EDZKOOL_DATA.company.studentsMentored} Students Empowered Globally`,
    `⚡ Free 1-on-1 Trial Class | Call ${EDZKOOL_DATA.company.phone}`,
    `🌍 Top Programs: IELTS, Coding, English & Academic Tuition`,
    `🎓 Enroll Now for Grades 1-10 | Premium 1-on-1 Online Tuition`,
    `🚀 Interactive Coding for Kids`,
  ];

  return (
    <div className="bg-bright-gradient text-white text-xs md:text-sm font-semibold py-2 overflow-hidden border-b border-orange-400/30">
      <div className="flex animate-marquee">
        {marqueeItems.map((item, idx) => (
          <span key={idx} className="flex items-center space-x-2 mr-12 shrink-0">
            <span>{item}</span>
            <span className="text-white font-black">|</span>
          </span>
        ))}
      </div>
    </div>
  );
}
