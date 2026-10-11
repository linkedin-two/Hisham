"use client";

import React, { useState } from "react";
import { EDZKOOL_DATA, Faq } from "@/data/edzkool-data";
import { ChevronDown, HelpCircle } from "lucide-react";

export default function FaqSection() {
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  const faqs = [
    {
      question: "How does 1-on-1 online coaching work?",
      answer: "Our coaching is conducted live over interactive online classrooms with dedicated expert faculty. Each session is personalized to the student's learning speed, featuring digital whiteboards, instant doubt resolution, and recorded sessions with notes.",
    },
    {
      question: "Are the medical universities abroad NMC & WHO recognized?",
      answer: "Yes, 100%. All partner universities are recognized by WHO and comply strictly with National Medical Commission (NMC) guidelines, featuring complete 6-year English medium clinical instruction.",
    },
    {
      question: "What are the documents required for medical admission?",
      answer: "You only need your 10th and 12th grade marksheets, NEET qualification score card, and a valid passport. Our dedicated documentation team manages apostille, translation, and ministry clearances.",
    },
    {
      question: "How do I download and access the Edzkool Mobile App?",
      answer: "You can download the official verified Android APK directly from our website. It is completely free, secure, and provides full access to NeXT/FMGE questions, notes, and live mentor updates.",
    },
  ];

  const toggleFaq = (idx: number) => {
    setOpenIdx(openIdx === idx ? null : idx);
  };

  return (
    <section id="faq" className="py-20 bg-slate-50/60">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center mb-14">
          <div className="inline-block bg-blue-50 text-[#103C82] font-bold text-xs px-3.5 py-1 rounded-full uppercase tracking-wider mb-2.5 border border-blue-100">
            Got Questions?
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-[#0B254E] tracking-tight">
            Frequently Asked Questions
          </h2>
          <p className="text-sm sm:text-base text-gray-500 font-normal mt-2.5">
            Everything students and parents need to know about our admissions and 1-on-1 coaching.
          </p>
        </div>

        {/* FAQ Accordion */}
        <div className="space-y-3.5">
          {faqs.map((faq, idx) => {
            const isOpen = openIdx === idx;
            return (
              <div
                key={idx}
                className="bg-white rounded-2xl border border-gray-100 shadow-xs overflow-hidden transition-all"
              >
                <button
                  onClick={() => toggleFaq(idx)}
                  className="w-full text-left px-6 py-5 font-bold text-gray-900 text-base sm:text-lg flex items-center justify-between space-x-4 hover:text-[#103C82] transition-colors"
                >
                  <div className="flex items-center space-x-3.5">
                    <HelpCircle className="w-5 h-5 text-[#103C82] shrink-0" />
                    <span className="text-base sm:text-lg font-bold text-[#0B254E]">{faq.question}</span>
                  </div>
                  <ChevronDown
                    className={`w-5 h-5 text-gray-400 shrink-0 transition-transform duration-300 ${
                      isOpen ? "rotate-180 text-[#103C82]" : ""
                    }`}
                  />
                </button>

                {isOpen && (
                  <div className="px-6 pb-6 pt-1 text-sm text-gray-600 font-normal leading-relaxed border-t border-gray-50 bg-slate-50/50">
                    <p className="pl-8">{faq.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
