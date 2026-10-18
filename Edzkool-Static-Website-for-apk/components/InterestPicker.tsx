"use client";

import React, { useState } from "react";
import Link from "next/link";

interface Recommendation {
  label: string;
  bg: string;
  title: string;
  text: string;
  href: string;
  img: string;
  alt: string;
}

export default function InterestPicker() {
  const [activeIdx, setActiveIdx] = useState(0);

  const recommendations: Recommendation[] = [
    {
      label: "Numbers and puzzles",
      bg: "#F4F8FE",
      title: "School Tuition, Grades 1 to 12",
      text: "Live subject classes in Maths, Science and more, with doubt-clearing and steady practice that builds real understanding.",
      href: "/programs",
      img: "/edzkool_new_images/programs-school-tuition.png",
      alt: "School tuition books and formulas",
    },
    {
      label: "Games and robots",
      bg: "#FFF8EC",
      title: "Coding and Robotics",
      text: "Hands-on projects where children build games, apps and ideas of their own, one working step at a time.",
      href: "/programs",
      img: "/edzkool_new_images/programs-coding-robotics.png",
      alt: "Coding and robotics friendly illustration",
    },
    {
      label: "Words and talking",
      bg: "#F4F8FE",
      title: "Language Courses",
      text: "Conversation-first lessons that get children speaking early and reading and writing with confidence.",
      href: "/programs",
      img: "/edzkool_new_images/programs-languages-courses.png",
      alt: "Language speech bubbles and conversation",
    },
    {
      label: "Earning a certificate",
      bg: "#FFF8EC",
      title: "Certification Courses",
      text: "Short live courses in coding, languages and academics that end with a project, an assessment and a certificate.",
      href: "/certifications",
      img: "/edzkool_new_images/programs-certificate.png",
      alt: "Certificate of completion with seal",
    },
  ];

  const current = recommendations[activeIdx];

  return (
    <section className="bg-white">
      <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-9">
        {/* Header */}
        <div className="flex flex-col gap-3.5 max-w-[680px]">
          <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
            Not sure where to start?
          </div>
          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
            What does your child love most?
          </h2>
        </div>

        {/* Tab Buttons */}
        <div role="tablist" aria-label="Interests" className="flex flex-wrap gap-3">
          {recommendations.map((rec, i) => {
            const isSelected = activeIdx === i;
            return (
              <button
                key={rec.label}
                role="tab"
                aria-selected={isSelected}
                onClick={() => setActiveIdx(i)}
                className={`rounded-full px-6 py-3 text-base font-bold min-h-[44px] transition-all ${
                  isSelected
                    ? "bg-[#144787] text-white border-2 border-[#144787] shadow-sm"
                    : "bg-white text-[#144787] border-2 border-[#C9D6EA] hover:border-[#144787]"
                }`}
              >
                {rec.label}
              </button>
            );
          })}
        </div>

        {/* Dynamic Card */}
        <div
          style={{ backgroundColor: current.bg }}
          className="rounded-[32px] p-8 md:p-11 flex flex-wrap gap-9 items-center border border-[#E3EAF4] transition-all"
        >
          <div className="flex-1 min-w-[280px] md:min-w-[340px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-xs md:text-[13px] tracking-widest uppercase">
              We suggest
            </div>
            <h3 className="font-serif text-2xl sm:text-3xl lg:text-[38px] text-[#0B2A5B] leading-tight font-bold">
              {current.title}
            </h3>
            <p className="text-base sm:text-[17px] leading-relaxed text-[#44546F]">
              {current.text}
            </p>
            <div className="pt-2">
              <Link
                href={current.href}
                className="inline-block bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                See this program
              </Link>
            </div>
          </div>

          <div className="flex-1 min-w-[260px] md:min-w-[320px] flex justify-center items-center">
            <img
              src={current.img}
              alt={current.alt}
              className="w-full max-w-[420px] h-auto object-contain block drop-shadow-xs"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
