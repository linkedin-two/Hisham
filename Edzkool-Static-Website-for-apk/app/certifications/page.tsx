"use client";

import React, { useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export default function CertificationsPage() {
  const [selectedCat, setSelectedCat] = useState("All");
  const [openFaq, setOpenFaq] = useState<number | null>(0);

  const categories = ["All", "Technology", "Languages", "Academic"];

  const courses = [
    {
      cat: "Technology",
      chip: "#144787",
      chipText: "#FFFFFF",
      bg: "#F4F8FE",
      level: "Beginner",
      title: "Python Programming Certificate",
      text: "Learn to think like a programmer and finish with a working project, from first lines of code to small games and tools.",
      duration: "8 Weeks",
      classes: "2 Live Classes / Wk",
    },
    {
      cat: "Technology",
      chip: "#144787",
      chipText: "#FFFFFF",
      bg: "#F4F8FE",
      level: "Beginner",
      title: "Web Development Foundations",
      text: "Build and publish a simple website using HTML, CSS and a little JavaScript with mentor feedback.",
      duration: "6 Weeks",
      classes: "2 Live Classes / Wk",
    },
    {
      cat: "Technology",
      chip: "#144787",
      chipText: "#FFFFFF",
      bg: "#F4F8FE",
      level: "Intermediate",
      title: "Robotics and Automation",
      text: "Design, wire and program small robots that sense and respond to the physical world.",
      duration: "10 Weeks",
      classes: "2 Live Classes / Wk",
    },
    {
      cat: "Languages",
      chip: "#FD9202",
      chipText: "#0B2A5B",
      bg: "#FFF8EC",
      level: "All levels",
      title: "Spoken English Certificate",
      text: "Confident everyday speaking, listening and presentation skills through live, supportive conversation practice.",
      duration: "8 Weeks",
      classes: "3 Live Classes / Wk",
    },
    {
      cat: "Languages",
      chip: "#FD9202",
      chipText: "#0B2A5B",
      bg: "#FFF8EC",
      level: "Beginner",
      title: "Foreign Language Starter",
      text: "A conversation-first start in Spanish, French, or German to develop early pronunciation and grammar instincts.",
      duration: "8 Weeks",
      classes: "2 Live Classes / Wk",
    },
    {
      cat: "Academic",
      chip: "#0B2A5B",
      chipText: "#FFFFFF",
      bg: "#F4F8FE",
      level: "Grades 8–12",
      title: "Maths Mastery Certificate",
      text: "Deepen problem solving and exam readiness with guided practice, mock tests, and mentor feedback.",
      duration: "12 Weeks",
      classes: "2 Live Classes / Wk",
    },
    {
      cat: "Academic",
      chip: "#0B2A5B",
      chipText: "#FFFFFF",
      bg: "#F4F8FE",
      level: "Grades 9–12",
      title: "Science Foundations",
      text: "Concept-first revision across physics, chemistry and biology with live demonstrations and real-world applications.",
      duration: "12 Weeks",
      classes: "2 Live Classes / Wk",
    },
  ];

  const filteredCourses =
    selectedCat === "All"
      ? courses
      : courses.filter((c) => c.cat === selectedCat);

  const steps = [
    {
      n: "01",
      title: "Choose a course",
      text: "Pick a certification path with your advisor after a free demo.",
    },
    {
      n: "02",
      title: "Learn live",
      text: "Join live classes with a mentor who guides every step.",
    },
    {
      n: "03",
      title: "Build and assess",
      text: "Complete a final project and a short, fair assessment.",
    },
    {
      n: "04",
      title: "Get certified",
      text: "Receive your certificate on successful completion.",
    },
  ];

  const faqs = [
    {
      q: "Who can take a certification course?",
      a: "Courses are open to learners across Grades 1 to 12, with each course noting its recommended level. Your advisor will help match the right one during your demo.",
    },
    {
      q: "How long does a certification course take?",
      a: "Most certification tracks run between 6 to 12 weeks with 2 to 3 live interactive classes per week plus guided weekly project work.",
    },
    {
      q: "Do I need to be an EDZKOOL tuition student?",
      a: "No. Certification courses can be taken on their own or alongside an ongoing school tuition track.",
    },
    {
      q: "What happens if my child needs extra help before the assessment?",
      a: "Mentors hold dedicated doubt-clearing sessions and provide 1-on-1 revision support so every learner feels prepared and confident before submitting their capstone project.",
    },
  ];

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      {/* Hero */}
      <section className="bg-gradient-to-b from-[#F4F8FE] to-white">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-12 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[420px] flex flex-col gap-6">
            <div className="inline-flex self-start bg-[#FFF1DB] text-[#8A4B00] text-[13px] font-bold tracking-wider uppercase px-3.5 py-2 rounded-full">
              Certification courses
            </div>
            <h1 className="font-serif text-4xl sm:text-5xl lg:text-[56px] leading-[1.08] font-bold text-[#0B2A5B] tracking-tight">
              Learn a skill. Finish with a certificate.
            </h1>
            <p className="text-lg sm:text-[19px] leading-relaxed text-[#44546F] max-w-[560px]">
              Short, focused live courses in tech, languages and academics, each ending with a project, an assessment and a certificate your child can be proud of.
            </p>
            <div className="flex flex-wrap gap-3.5 pt-2">
              <a
                href="#courses"
                className="bg-[#144787] hover:bg-[#0E3566] text-white font-bold text-base px-7 py-4 rounded-full transition-transform transform hover:-translate-y-0.5"
              >
                Browse certification courses
              </a>
              <Link
                href="/contact"
                className="bg-white hover:bg-gray-50 text-[#144787] font-bold text-base px-6 py-3.5 rounded-full border-2 border-[#144787] transition-colors"
              >
                Talk to an advisor
              </Link>
            </div>
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/certificates-top-section.png"
              alt="A certificate of completion with a gold seal and ribbon"
              className="w-full max-w-[520px] h-auto object-contain block drop-shadow-xs rounded-2xl"
            />
          </div>
        </div>
      </section>

      {/* What you get band */}
      <section className="bg-[#144787] text-white">
        <div className="max-w-[1200px] mx-auto px-6 py-11 grid grid-cols-2 lg:grid-cols-4 gap-7 md:gap-9">
          <div>
            <div className="font-serif text-2xl sm:text-[26px] font-bold text-[#FFB84D]">
              Live mentor
            </div>
            <div className="text-[15px] opacity-90 mt-1 font-medium">
              Real teachers, not recordings
            </div>
          </div>
          <div>
            <div className="font-serif text-2xl sm:text-[26px] font-bold text-[#FFB84D]">
              Final project
            </div>
            <div className="text-[15px] opacity-90 mt-1 font-medium">
              Something real to show
            </div>
          </div>
          <div>
            <div className="font-serif text-2xl sm:text-[26px] font-bold text-[#FFB84D]">
              Assessment
            </div>
            <div className="text-[15px] opacity-90 mt-1 font-medium">
              Fair, clear and stress-light
            </div>
          </div>
          <div>
            <div className="font-serif text-2xl sm:text-[26px] font-bold text-[#FFB84D]">
              Certificate
            </div>
            <div className="text-[15px] opacity-90 mt-1 font-medium">
              On successful completion
            </div>
          </div>
        </div>
      </section>

      {/* Catalogue */}
      <section id="courses" className="bg-white">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-9">
          <div className="flex flex-col gap-3.5 max-w-[700px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Course catalogue
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Pick a certification path.
            </h2>
            <p className="text-base text-[#5B6B85] leading-relaxed">
              Explore short-term live courses designed to build practical mastery and portfolio projects.
            </p>
          </div>

          {/* Category Tabs */}
          <div role="tablist" aria-label="Course categories" className="flex flex-wrap gap-3">
            {categories.map((cat) => {
              const isSelected = selectedCat === cat;
              return (
                <button
                  key={cat}
                  role="tab"
                  aria-selected={isSelected}
                  onClick={() => setSelectedCat(cat)}
                  className={`rounded-full px-6 py-3 text-base font-bold min-h-[44px] transition-all ${
                    isSelected
                      ? "bg-[#144787] text-white border-2 border-[#144787] shadow-sm"
                      : "bg-white text-[#144787] border-2 border-[#C9D6EA] hover:border-[#144787]"
                  }`}
                >
                  {cat}
                </button>
              );
            })}
          </div>

          {/* Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredCourses.map((c, idx) => (
              <article
                key={idx}
                style={{ backgroundColor: c.bg }}
                className="rounded-3xl p-7 flex flex-col gap-3.5 border border-[#E3EAF4] shadow-xs"
              >
                <div className="flex justify-between items-center gap-2.5">
                  <span
                    style={{ backgroundColor: c.chip, color: c.chipText }}
                    className="text-xs font-bold tracking-wider uppercase px-3 py-1.5 rounded-full"
                  >
                    {c.cat}
                  </span>
                  <span className="text-xs font-bold text-[#A85B00]">
                    {c.level}
                  </span>
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#0B2A5B] leading-snug">
                  {c.title}
                </h3>
                <p className="text-[15px] leading-relaxed text-[#44546F] flex-1">
                  {c.text}
                </p>
                <div className="flex flex-wrap gap-x-4 gap-y-1 text-sm font-semibold text-[#144787] pt-2 border-t border-black/5">
                  <span>{c.duration}</span>
                  <span>•</span>
                  <span>{c.classes}</span>
                  <span>•</span>
                  <span>Certificate ✓</span>
                </div>
                <Link
                  href="/contact"
                  className="mt-2 font-bold text-[15px] text-[#144787] hover:text-[#0B2A5B] flex items-center gap-1 group"
                >
                  <span>Enquire about this course</span>
                  <span className="transition-transform group-hover:translate-x-1">→</span>
                </Link>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* How certification works */}
      <section className="bg-[#F4F8FE]">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-12">
          <div className="flex flex-col gap-3.5 max-w-[680px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              How certification works
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              From first class to certificate in four steps.
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {steps.map((st) => (
              <div
                key={st.n}
                className="bg-white rounded-[22px] p-7 md:p-8 flex flex-col gap-3.5 border border-[#E3EAF4] shadow-xs"
              >
                <div className="font-serif text-4xl sm:text-[44px] font-bold text-[#FD9202] leading-none">
                  {st.n}
                </div>
                <h3 className="text-xl sm:text-[22px] font-bold text-[#0B2A5B]">
                  {st.title}
                </h3>
                <p className="text-[15px] leading-relaxed text-[#44546F]">
                  {st.text}
                </p>
              </div>
            ))}
          </div>

          <div className="bg-white border border-dashed border-[#C9D6EA] rounded-2xl p-5 text-[15px] text-[#5B6B85] leading-relaxed max-w-[780px]">
            Certificates are awarded upon meeting minimum attendance, project submission, and continuous educator assessment. Digital verifiable credentials and printable certificates are issued.
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="bg-white">
        <div className="max-w-[900px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-9">
          <div className="flex flex-col gap-3.5">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Certification FAQ
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Good to know before you enrol.
            </h2>
          </div>

          <div className="flex flex-col divide-y divide-[#DCE5F2] border-y border-[#DCE5F2]">
            {faqs.map((f, i) => {
              const isOpen = openFaq === i;
              return (
                <div key={i} className="py-2">
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : i)}
                    aria-expanded={isOpen}
                    className="w-full flex justify-between items-center gap-5 py-5 text-left text-lg md:text-[19px] font-bold text-[#0B2A5B] transition-colors"
                  >
                    <span>{f.q}</span>
                    <span className="shrink-0 w-9 h-9 rounded-full bg-[#EAF1FB] text-[#144787] flex items-center justify-center text-xl font-bold">
                      {isOpen ? "−" : "+"}
                    </span>
                  </button>
                  {isOpen && (
                    <p className="text-base leading-relaxed text-[#44546F] pb-5 pr-12">
                      {f.a}
                    </p>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Pre-Footer CTA */}
      <section className="bg-[#144787] text-white">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-7 items-center justify-between">
          <div className="flex-1 min-w-[300px] md:min-w-[440px] flex flex-col gap-3">
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight font-bold">
              Not sure which course fits?
            </h2>
            <p className="text-base sm:text-[17px] text-[#D6E3F6] leading-relaxed">
              Book a free demo and our advisor will match a certification to your child’s age and goals.
            </p>
          </div>
          <Link
            href="/contact"
            className="bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-base md:text-[17px] px-8 py-4 rounded-full inline-block transition-transform transform hover:-translate-y-0.5 shadow-md"
          >
            Book a free demo class
          </Link>
        </div>
      </section>

      <Footer />
    </main>
  );
}
