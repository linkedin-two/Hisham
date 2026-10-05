"use client";

import React, { useState } from "react";
import { EDZKOOL_DATA, Faq } from "@/data/edzkool-data";
import { ChevronDown, HelpCircle } from "lucide-react";

export default function FaqSection() {
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  const toggleFaq = (idx: number) => {
    setOpenIdx(openIdx === idx ? null : idx);
  };

  return (
    <section id="faq" className="py-20 bg-bright-bg/60">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center mb-16">
          <div className="inline-block bg-purple-100 text-bright-purple font-extrabold text-xs px-4 py-1.5 rounded-pill uppercase tracking-widest mb-3">
            Got Questions?
          </div>
          <h2 className="text-3xl sm:text-4xl font-black text-gray-900 tracking-tight">
            Frequently Asked Questions
          </h2>
          <p className="text-base text-gray-600 font-medium mt-3">
            Everything parents and parents and students need to know about our coaching.
          </p>
        </div>

        {/* FAQ Accordion */}
        <div className="space-y-4">
          {EDZKOOL_DATA.faqs.map((faq: Faq, idx: number) => {
            const isOpen = openIdx === idx;
            return (
              <div
                key={idx}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden transition-all"
              >
                <button
                  onClick={() => toggleFaq(idx)}
                  className="w-full text-left px-6 py-5 font-extrabold text-gray-900 text-base sm:text-lg flex items-center justify-between space-x-4 hover:text-bright-purple transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <HelpCircle className="w-5 h-5 text-bright-purple shrink-0" />
                    <span>{faq.question}</span>
                  </div>
                  <ChevronDown
                    className={`w-5 h-5 text-gray-400 shrink-0 transition-transform duration-300 ${
                      isOpen ? "rotate-180 text-bright-purple" : ""
                    }`}
                  />
                </button>

                {isOpen && (
                  <div className="px-6 pb-6 pt-1 text-sm text-gray-600 font-medium leading-relaxed border-t border-gray-50 bg-gray-50/50">
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
