"use client";

import React, { useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export default function ContactPage() {
  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const [formSubmitted, setFormSubmitted] = useState(false);
  const [formData, setFormData] = useState({
    parentName: "",
    phone: "",
    grade: "",
    interest: "",
  });

  const faqs = [
    {
      q: "Which grades do you teach?",
      a: "EDZKOOL offers online tuition and school-subject classes for Grades 1 to 12, plus coding and language courses for learners of different ages.",
    },
    {
      q: "Are classes live?",
      a: "Yes. Classes are live and interactive, so students can ask questions and get feedback during the session.",
    },
    {
      q: "Is there a free demo class?",
      a: "Yes. Book a free demo and our team will contact you to arrange a class that suits your child’s grade and interests.",
    },
    {
      q: "What do we need to attend?",
      a: "A laptop, tablet or computer with a stable internet connection is enough. We guide you through setup before the first class.",
    },
    {
      q: "Can my child take tuition and coding or a language together?",
      a: "Yes. Many families combine a tuition track with a skill course. Our advisor will help you plan a balanced weekly schedule.",
    },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.parentName || !formData.phone) {
      alert("Please fill in your name and contact phone number.");
      return;
    }
    setFormSubmitted(true);
  };

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      {/* Demo form + details banner */}
      <section className="bg-[#144787] text-white">
        <div className="max-w-[1200px] mx-auto px-6 py-20 flex flex-wrap gap-14 items-center">
          {/* Left Column: Information */}
          <div className="flex-1 min-w-[280px] md:min-w-[380px] flex flex-col gap-5">
            <div className="text-[#FFB84D] font-bold text-sm tracking-widest uppercase">
              Contact
            </div>
            <h1 className="font-serif text-4xl sm:text-5xl lg:text-[54px] leading-tight font-bold tracking-tight">
              Book a free demo class.
            </h1>
            <p className="text-lg leading-relaxed text-[#D6E3F6] max-w-[480px]">
              Tell us a little about your child. Our team will call to plan a demo that fits their grade and goals.
            </p>

            <div className="flex flex-col gap-4 mt-3 text-base">
              <div>
                <div className="text-xs font-bold tracking-widest uppercase text-[#FFB84D]">
                  Phone / WhatsApp
                </div>
                <div className="mt-1 font-semibold text-lg text-white">
                  +91 98765 43210
                </div>
              </div>

              <div>
                <div className="text-xs font-bold tracking-widest uppercase text-[#FFB84D]">
                  Email
                </div>
                <div className="mt-1 font-semibold text-white">
                  care@edzkool.com
                </div>
              </div>

              <div>
                <div className="text-xs font-bold tracking-widest uppercase text-[#FFB84D]">
                  Address
                </div>
                <div className="mt-1 text-white/90">
                  HSR Layout, Bengaluru, Karnataka, India
                </div>
              </div>

              <div>
                <div className="text-xs font-bold tracking-widest uppercase text-[#FFB84D]">
                  Admissions Hours
                </div>
                <div className="mt-1 text-white/90">
                  Monday – Saturday: 9:00 AM – 8:00 PM IST
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Form */}
          <div className="flex-1 min-w-[280px] md:min-w-[400px] bg-white rounded-[28px] p-8 md:p-10 text-[#1B2A44] shadow-xl">
            {formSubmitted ? (
              <div className="text-center py-10 space-y-4">
                <div className="w-16 h-16 rounded-full bg-[#EAF1FB] text-[#144787] flex items-center justify-center text-3xl mx-auto font-bold">
                  ✓
                </div>
                <h3 className="font-serif text-3xl font-bold text-[#0B2A5B]">
                  Demo Requested!
                </h3>
                <p className="text-base text-[#44546F] leading-relaxed max-w-sm mx-auto">
                  Thank you, <strong>{formData.parentName}</strong>. Our academic counselor will call you at <strong>{formData.phone}</strong> shortly to confirm your child&apos;s demo slot.
                </p>
                <button
                  onClick={() => {
                    setFormSubmitted(false);
                    setFormData({ parentName: "", phone: "", grade: "", interest: "" });
                  }}
                  className="bg-[#144787] text-white font-bold text-sm px-6 py-2.5 rounded-full mt-4"
                >
                  Book another demo
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-4">
                <div className="flex flex-col gap-1.5">
                  <label htmlFor="pname" className="text-sm font-bold text-[#0B2A5B]">
                    Parent name
                  </label>
                  <input
                    id="pname"
                    type="text"
                    required
                    placeholder="Your name"
                    value={formData.parentName}
                    onChange={(e) => setFormData({ ...formData, parentName: e.target.value })}
                    className="font-sans text-base px-4 py-3.5 border border-[#C9D6EA] rounded-xl focus:border-[#144787] focus:outline-none text-[#1B2A44]"
                  />
                </div>

                <div className="flex flex-col gap-1.5">
                  <label htmlFor="phone" className="text-sm font-bold text-[#0B2A5B]">
                    Phone / WhatsApp
                  </label>
                  <input
                    id="phone"
                    type="tel"
                    required
                    placeholder="e.g. +91 98765 43210"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="font-sans text-base px-4 py-3.5 border border-[#C9D6EA] rounded-xl focus:border-[#144787] focus:outline-none text-[#1B2A44]"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="grade" className="text-sm font-bold text-[#0B2A5B]">
                      Child&apos;s grade
                    </label>
                    <select
                      id="grade"
                      value={formData.grade}
                      onChange={(e) => setFormData({ ...formData, grade: e.target.value })}
                      className="font-sans text-base px-4 py-3.5 border border-[#C9D6EA] rounded-xl focus:border-[#144787] focus:outline-none text-[#1B2A44] bg-white"
                    >
                      <option value="">Select Grade</option>
                      {[...Array(12)].map((_, i) => (
                        <option key={i + 1} value={`Grade ${i + 1}`}>
                          Grade {i + 1}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="interest" className="text-sm font-bold text-[#0B2A5B]">
                      Interested in
                    </label>
                    <select
                      id="interest"
                      value={formData.interest}
                      onChange={(e) => setFormData({ ...formData, interest: e.target.value })}
                      className="font-sans text-base px-4 py-3.5 border border-[#C9D6EA] rounded-xl focus:border-[#144787] focus:outline-none text-[#1B2A44] bg-white"
                    >
                      <option value="">Select Subject</option>
                      <option value="School Tuition (Math & Science)">School Tuition</option>
                      <option value="Coding & Robotics">Coding & Robotics</option>
                      <option value="Language Courses">Language Courses</option>
                      <option value="Certification Courses">Certification Courses</option>
                    </select>
                  </div>
                </div>

                <button
                  type="submit"
                  className="bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-[17px] py-4 px-7 rounded-full mt-2 transition-transform transform hover:-translate-y-0.5 shadow-sm"
                >
                  Request my free demo
                </button>

                <p className="text-xs text-[#5B6B85] leading-relaxed text-center">
                  We only use these details to contact you about scheduling your child&apos;s demo class.
                </p>
              </form>
            )}
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="bg-white">
        <div className="max-w-[900px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-9">
          <div className="flex flex-col gap-3.5">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              FAQ
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Questions parents ask first.
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

      <Footer />
    </main>
  );
}
