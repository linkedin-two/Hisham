import React from "react";
import { Check, X, Sparkles } from "lucide-react";

interface ComparisonProps {
  onOpenModal: () => void;
}

export default function ComparisonSection({ onOpenModal }: ComparisonProps) {
  const comparisonItems = [
    {
      feature: "NMC & WHO University Verification",
      traditional: "High risk of joining non-NMC approved bilingual courses",
      edzkool: "100% Guaranteed NMC & WHO Listed 6-Year English Medium",
    },
    {
      feature: "Fee Transparency & Donations",
      traditional: "Hidden agent commissions, forced exchange fees, donation demands",
      edzkool: "0% Donation, direct payment to university bank account",
    },
    {
      feature: "Legal & Embassy Apostille Work",
      traditional: "Students left to deal with embassy approvals & police clearance alone",
      edzkool: "Complete in-house MEA/HRD apostille & 99.8% visa guarantee",
    },
    {
      feature: "Post-Arrival & Campus Support",
      traditional: "Agent disappears after student lands at destination airport",
      edzkool: "12+ Local global centers, airport pickup, hostel & Indian mess setup",
    },
    {
      feature: "FMGE / NeXT Exam Mentorship",
      traditional: "No academic support for Indian licensing exams",
      edzkool: "Free NeXT Exam Coaching App & Live guidance by Indian doctors",
    },
  ];

  return (
    <section id="why-us" className="py-20 bg-[#F0F4FA]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-block bg-[#EBF2FD] text-[#103C82] font-extrabold text-xs px-4 py-1.5 rounded-pill uppercase tracking-widest mb-3 border border-[#103C82]/20">
            Clear Difference
          </div>
          <h2 className="text-3xl sm:text-4xl font-black text-gray-900 tracking-tight">
            Unverified Agents vs The Edzkool Way
          </h2>
          <p className="text-base text-gray-600 font-medium mt-3">
            Discover why over 300+ students trust Edzkool for their online tuition.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="bg-white rounded-3xl p-8 border border-gray-200 shadow-sm relative">
            <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-gray-100">
              <div className="w-10 h-10 rounded-full bg-gray-100 text-gray-500 flex items-center justify-center font-black">
                <X className="w-6 h-6 text-red-500" />
              </div>
              <div>
                <h3 className="text-xl font-extrabold text-gray-700">Traditional Unverified Agents</h3>
                <span className="text-xs text-gray-400 font-semibold">High risk, hidden charges, no post-arrival support</span>
              </div>
            </div>

            <div className="space-y-6">
              {comparisonItems.map((item, idx) => (
                <div key={idx} className="flex items-start space-x-3 text-sm">
                  <div className="w-5 h-5 rounded-full bg-red-100 text-red-600 flex items-center justify-center shrink-0 mt-0.5">
                    <X className="w-3.5 h-3.5" />
                  </div>
                  <div>
                    <span className="font-bold text-gray-900 block mb-0.5">{item.feature}</span>
                    <span className="text-gray-500 text-xs font-medium">{item.traditional}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-[#103C82] text-white rounded-3xl p-8 shadow-2xl relative border-2 border-[#F58220] overflow-hidden">
            <div className="absolute top-0 right-0 bg-[#F58220] text-white font-black text-[10px] px-4 py-1.5 rounded-bl-2xl uppercase tracking-wider">
              RECOMMENDED CHOICE
            </div>

            <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-blue-800">
              <div className="w-10 h-10 rounded-full bg-[#F58220] text-white flex items-center justify-center font-black">
                <Sparkles className="w-6 h-6 fill-white" />
              </div>
              <div>
                <h3 className="text-xl font-black text-white">The Edzkool Way</h3>
                <span className="text-xs text-[#F58220] font-extrabold">100% Transparent, A-Z Lifetime Support</span>
              </div>
            </div>

            <div className="space-y-6">
              {comparisonItems.map((item, idx) => (
                <div key={idx} className="flex items-start space-x-3 text-sm">
                  <div className="w-5 h-5 rounded-full bg-[#F58220] text-white flex items-center justify-center shrink-0 mt-0.5 font-black">
                    <Check className="w-3.5 h-3.5 stroke-[3]" />
                  </div>
                  <div>
                    <span className="font-extrabold text-white block mb-0.5">{item.feature}</span>
                    <span className="text-blue-100 text-xs font-medium">{item.edzkool}</span>
                  </div>
                </div>
              ))}
            </div>

            <div className="mt-8 pt-4 border-t border-blue-800 text-center">
              <button
                onClick={onOpenModal}
                className="bg-[#F58220] hover:bg-[#D96C0D] text-white font-black px-8 py-3.5 rounded-pill text-sm transition-transform hover:scale-105 shadow-md"
              >
                Start Your Safe Medical Journey →
              </button>
            </div>
          </div>
        </div>

      </div>
    </section>
  );
}
