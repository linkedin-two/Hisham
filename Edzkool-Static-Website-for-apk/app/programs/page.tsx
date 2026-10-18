"use client";

import React, { useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import CtaBand from "@/components/CtaBand";

export default function ProgramsPage() {
  const [activeBand, setActiveBand] = useState(0);

  const bands = [
    {
      label: "Grades 1–4",
      blurb:
        "A joyful foundation. Short, playful live sessions build reading, number sense and the habit of asking questions.",
      subjects: [
        "English",
        "Maths",
        "Environmental Science",
        "Coding for beginners",
        "Language starter",
      ],
    },
    {
      label: "Grades 5–7",
      blurb:
        "Concepts get deeper. Teachers connect ideas across subjects and encourage children to explain their thinking.",
      subjects: [
        "English",
        "Maths",
        "Science",
        "Social Science",
        "Coding",
        "Languages",
      ],
    },
    {
      label: "Grades 8–10",
      blurb:
        "Board-year focus with steady practice, regular revision and clear feedback, plus room for a skill course.",
      subjects: [
        "English",
        "Maths",
        "Science",
        "Social Science",
        "Board exam practice",
        "Coding",
      ],
    },
    {
      label: "Grades 11–12",
      blurb:
        "Subject depth and exam readiness, with mentors who help students plan revision and stay on track.",
      subjects: [
        "Maths",
        "Physics",
        "Chemistry",
        "Biology",
        "Commerce subjects",
        "Computer Science",
      ],
    },
  ];

  const currentBand = bands[activeBand];

  const sampleWeek = [
    {
      day: "Mon",
      title: "Maths",
      note: "Live concept class with guided practice.",
      bg: "#F4F8FE",
    },
    {
      day: "Tue",
      title: "Science",
      note: "Questions, demos and quick revision.",
      bg: "#FFF8EC",
    },
    {
      day: "Wed",
      title: "English",
      note: "Reading, writing and speaking together.",
      bg: "#F4F8FE",
    },
    {
      day: "Thu",
      title: "Coding",
      note: "Build a small project, step by step.",
      bg: "#FFF8EC",
    },
    {
      day: "Fri",
      title: "Language club",
      note: "Relaxed conversation and games.",
      bg: "#F4F8FE",
    },
  ];

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      {/* Page Header */}
      <section className="bg-gradient-to-b from-[#F4F8FE] to-white">
        <div className="max-w-[1200px] mx-auto px-6 pt-16 pb-12 flex flex-col gap-4">
          <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
            Programs
          </div>
          <h1 className="font-serif text-4xl sm:text-5xl lg:text-[56px] leading-[1.08] font-bold text-[#0B2A5B] tracking-tight">
            Three ways to learn, one friendly school.
          </h1>
          <p className="text-lg sm:text-[19px] leading-relaxed text-[#44546F] max-w-[640px]">
            Pick a full tuition track, add a skill course, or do both. Every program starts with a free demo class.
          </p>

          <div className="flex flex-wrap gap-3 pt-2">
            <a
              href="#tuition"
              className="bg-white border-2 border-[#C9D6EA] hover:border-[#144787] text-[#144787] rounded-full px-5 py-2.5 font-bold text-[15px] transition-colors"
            >
              School Tuition
            </a>
            <a
              href="#coding"
              className="bg-white border-2 border-[#C9D6EA] hover:border-[#144787] text-[#144787] rounded-full px-5 py-2.5 font-bold text-[15px] transition-colors"
            >
              Coding
            </a>
            <a
              href="#languages"
              className="bg-white border-2 border-[#C9D6EA] hover:border-[#144787] text-[#144787] rounded-full px-5 py-2.5 font-bold text-[15px] transition-colors"
            >
              Languages
            </a>
            <a
              href="#certifications"
              className="bg-white border-2 border-[#FD9202] text-[#0B2A5B] rounded-full px-5 py-2.5 font-bold text-[15px] transition-colors"
            >
              Certification courses
            </a>
          </div>
        </div>
      </section>

      {/* 1. School Tuition */}
      <section id="tuition" className="bg-white border-t border-[#E3EAF4]">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-12 lg:gap-14 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/programs-school-tuition.png"
              alt="School Tuition books and formulas"
              className="w-full max-w-[480px] h-auto object-contain block rounded-2xl shadow-xs"
            />
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Grades 1 to 12
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl text-[#0B2A5B] font-bold">
              School Tuition
            </h2>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              Live subject classes that follow your child’s school syllabus, with room to ask questions, revise and practise until ideas click.
            </p>
            <div className="flex flex-wrap gap-2.5 pt-1">
              {["English", "Maths", "Science", "Social Science", "Exam practice"].map((s) => (
                <span
                  key={s}
                  className="bg-[#EAF1FB] text-[#144787] font-semibold text-sm px-3.5 py-2 rounded-full"
                >
                  {s}
                </span>
              ))}
            </div>
            <div className="pt-2">
              <Link
                href="/contact"
                className="inline-block bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                Try a free class
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* 2. Coding and Robotics */}
      <section id="coding" className="bg-[#FFF8EC]">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap-reverse gap-12 lg:gap-14 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Skill course
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl text-[#0B2A5B] font-bold">
              Coding and Robotics
            </h2>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              Children learn by making: games, apps and small machines that actually work. Each class ends with something they built themselves.
            </p>
            <div className="flex flex-wrap gap-2.5 pt-1">
              {["Game creation", "App building", "Web basics", "Robotics"].map((s) => (
                <span
                  key={s}
                  className="bg-white text-[#144787] font-semibold text-sm px-3.5 py-2 rounded-full border border-[#F3E3C8]"
                >
                  {s}
                </span>
              ))}
            </div>
            <div className="pt-2">
              <Link
                href="/contact"
                className="inline-block bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                Try a free class
              </Link>
            </div>
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/programs-coding-robotics.png"
              alt="Coding and robotics robot illustration"
              className="w-full max-w-[480px] h-auto object-contain block rounded-2xl shadow-xs"
            />
          </div>
        </div>
      </section>

      {/* 3. Language Courses */}
      <section id="languages" className="bg-white">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-12 lg:gap-14 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/programs-languages-courses.png"
              alt="Speech bubbles greeting in different languages"
              className="w-full max-w-[480px] h-auto object-contain block rounded-2xl shadow-xs"
            />
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Skill course
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl text-[#0B2A5B] font-bold">
              Language Courses
            </h2>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              Conversation-first lessons that get children speaking early, then reading and writing with confidence.
            </p>
            <div className="bg-[#F4F8FE] rounded-2xl p-4 text-[15px] text-[#5B6B85] leading-relaxed">
              Available in English, French, Spanish, German, Arabic, and Hindi with certified native-level educators.
            </div>
            <div className="pt-2">
              <Link
                href="/contact"
                className="inline-block bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                Try a free class
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* 4. Certification Courses Preview */}
      <section id="certifications" className="bg-[#FFF8EC]">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap-reverse gap-12 lg:gap-14 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              New
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl text-[#0B2A5B] font-bold">
              Certification Courses
            </h2>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              Short, focused live courses in tech, languages and academics. Each ends with a final project, an assessment and a certificate.
            </p>
            <div className="flex flex-wrap gap-2.5 pt-1">
              {["Python", "Web development", "Spoken English", "Maths mastery"].map((s) => (
                <span
                  key={s}
                  className="bg-white text-[#144787] font-semibold text-sm px-3.5 py-2 rounded-full border border-[#F3E3C8]"
                >
                  {s}
                </span>
              ))}
            </div>
            <div className="pt-2">
              <Link
                href="/certifications"
                className="inline-block bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                Explore certification courses
              </Link>
            </div>
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/programs-certificate.png"
              alt="A certificate of completion with a gold seal"
              className="w-full max-w-[480px] h-auto object-contain block rounded-2xl shadow-xs"
            />
          </div>
        </div>
      </section>

      {/* 5. Grade Finder Interactive Explorer */}
      <section className="bg-[#F4F8FE]">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-9">
          <div className="flex flex-col gap-3.5 max-w-[680px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Find your grade
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Pick a grade, see what your child will learn.
            </h2>
          </div>

          <div role="tablist" aria-label="Grade bands" className="flex flex-wrap gap-3">
            {bands.map((b, i) => {
              const isSelected = activeBand === i;
              return (
                <button
                  key={b.label}
                  role="tab"
                  aria-selected={isSelected}
                  onClick={() => setActiveBand(i)}
                  className={`rounded-full px-6 py-3 text-base font-bold min-h-[44px] transition-all ${
                    isSelected
                      ? "bg-[#144787] text-white border-2 border-[#144787] shadow-sm"
                      : "bg-[#F4F8FE] text-[#144787] border-2 border-[#C9D6EA] hover:border-[#144787]"
                  }`}
                >
                  {b.label}
                </button>
              );
            })}
          </div>

          <div className="bg-white rounded-[28px] p-8 md:p-10 border border-[#E3EAF4] flex flex-wrap gap-8 shadow-xs">
            <div className="flex-1 min-w-[280px] md:min-w-[340px] flex flex-col gap-4">
              <h3 className="font-serif text-2xl sm:text-3xl text-[#0B2A5B] font-bold">
                {currentBand.label}
              </h3>
              <p className="text-[17px] leading-relaxed text-[#44546F]">
                {currentBand.blurb}
              </p>
              <div className="pt-2">
                <Link
                  href="/contact"
                  className="inline-block bg-[#FD9202] text-[#0B2A5B] font-bold text-base px-6 py-3.5 rounded-full hover:brightness-105 transition-all"
                >
                  Book a demo for this grade
                </Link>
              </div>
            </div>

            <div className="flex-1 min-w-[280px] md:min-w-[320px] grid grid-cols-2 gap-3 content-start">
              {currentBand.subjects.map((sub) => (
                <div
                  key={sub}
                  className="bg-[#F1F6FD] rounded-2xl p-4 font-semibold text-[#144787] text-[15px]"
                >
                  {sub}
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 6. Sample Week Routine */}
      <section className="bg-white">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-10">
          <div className="flex flex-col gap-3.5 max-w-[680px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              A sample week
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Balanced days, steady progress.
            </h2>
            <p className="text-base text-[#5B6B85] leading-relaxed">
              An example only. Your advisor sets the real schedule around your child.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {sampleWeek.map((day) => (
              <div
                key={day.day}
                style={{ backgroundColor: day.bg }}
                className="rounded-[22px] p-6 flex flex-col gap-2 border border-[#E3EAF4] shadow-xs"
              >
                <div className="text-xs font-bold tracking-widest uppercase text-[#A85B00]">
                  {day.day}
                </div>
                <div className="font-serif text-xl sm:text-[22px] font-bold text-[#0B2A5B]">
                  {day.title}
                </div>
                <div className="text-sm text-[#44546F] leading-relaxed">
                  {day.note}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pre-Footer CTA */}
      <CtaBand />

      {/* Footer */}
      <Footer />
    </main>
  );
}
