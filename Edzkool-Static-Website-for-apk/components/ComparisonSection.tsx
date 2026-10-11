import React from "react";
import { Check, X, Sparkles } from "lucide-react";

interface ComparisonProps {
  onOpenModal: () => void;
}

export default function ComparisonSection({ onOpenModal }: ComparisonProps) {
  const traditionalPoints = [
    {
      title: "Hidden Costs & Extra Fees",
      desc: "Students charged unexpected fees and inflated exchange rates after admission.",
    },
    {
      title: "No Post-Arrival Support",
      desc: "Left alone at destination airport with no hostel orientation or local support.",
    },
    {
      title: "Unclear University Accreditation",
      desc: "Risk of joining non-NMC approved bilingual colleges without proper verification.",
    },
    {
      title: "Fake Pass-Rate Promises",
      desc: "No academic backing, licensing guidance or FMGE / NeXT preparation classes.",
    },
    {
      title: "Zero Accountability",
      desc: "Agent disappears once initial commissions and advance fees are collected.",
    },
  ];

  const edzkoolPoints = [
    {
      title: "100% Direct University Fee Policy",
      desc: "Zero donations. All tuition fees paid directly to official university bank accounts.",
    },
    {
      title: "Guaranteed Post-Arrival Support",
      desc: "Airport reception, hostel allocation, local SIM card and Indian mess arrangements.",
    },
    {
      title: "NMC & WHO Verified Universities",
      desc: "Admissions strictly to 100% English medium recognized medical institutions.",
    },
    {
      title: "FMGE / NeXT Prep & Mobile App",
      desc: "Integrated exam coaching with live classes, flashcards and doctor mentorship.",
    },
    {
      title: "Complete 6-Year Student Guardianship",
      desc: "Dedicated personal coordinator available 24/7 throughout your entire medical degree.",
    },
  ];

  return (
    <section id="comparison" className="py-20 bg-slate-50/60">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-14">
          <div className="inline-block bg-blue-50 text-[#103C82] font-bold text-xs px-3.5 py-1 rounded-full uppercase tracking-wider mb-2.5 border border-blue-100">
            Why Choose Us
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-[#0B254E] tracking-tight">
            Unverified Agents vs The Edzkool Way
          </h2>
          <p className="text-sm sm:text-base text-gray-500 font-normal mt-2.5">
            Make an informed, transparent choice for your medical education and international career.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-stretch">
          {/* Traditional Agents Card */}
          <div className="bg-white rounded-3xl p-7 sm:p-9 border border-gray-200/80 shadow-xs flex flex-col justify-between">
            <div>
              <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-gray-100">
                <div className="w-10 h-10 rounded-full bg-red-50 text-red-500 flex items-center justify-center font-black">
                  <X className="w-5 h-5 stroke-[2.5]" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-gray-800">Traditional Unverified Agents</h3>
                  <span className="text-xs text-gray-400 font-medium">High risk, hidden charges & lack of accountability</span>
                </div>
              </div>

              <div className="space-y-5">
                {traditionalPoints.map((item, idx) => (
                  <div key={idx} className="flex items-start space-x-3">
                    <div className="w-5 h-5 rounded-full bg-red-100 text-red-600 flex items-center justify-center shrink-0 mt-0.5">
                      <X className="w-3 h-3 stroke-[2.5]" />
                    </div>
                    <div>
                      <span className="font-bold text-gray-800 text-sm block mb-0.5">{item.title}</span>
                      <span className="text-gray-500 text-xs font-normal leading-relaxed">{item.desc}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* The Edzkool Way Card */}
          <div className="bg-[#0E2954] text-white rounded-3xl p-7 sm:p-9 shadow-xl relative border border-blue-900/50 flex flex-col justify-between overflow-hidden">
            <div className="absolute top-0 right-0 bg-[#F58220] text-white font-black text-[10px] px-4 py-1.5 rounded-bl-2xl uppercase tracking-wider shadow-sm">
              RECOMMENDED CHOICE
            </div>

            <div>
              <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-white/10">
                <div className="w-10 h-10 rounded-full bg-[#F58220] text-white flex items-center justify-center font-bold">
                  <Sparkles className="w-5 h-5 fill-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-white">The Edzkool Way</h3>
                  <span className="text-xs text-[#F58220] font-bold">100% Transparent, Verified Direct Admissions</span>
                </div>
              </div>

              <div className="space-y-5">
                {edzkoolPoints.map((item, idx) => (
                  <div key={idx} className="flex items-start space-x-3">
                    <div className="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                      <Check className="w-3 h-3 stroke-[3]" />
                    </div>
                    <div>
                      <span className="font-bold text-white text-sm block mb-0.5">{item.title}</span>
                      <span className="text-blue-100/80 text-xs font-normal leading-relaxed">{item.desc}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="mt-8 pt-5 border-t border-white/10 text-center">
              <button
                onClick={onOpenModal}
                className="w-full bg-[#F58220] hover:bg-[#E07310] text-white font-bold py-3.5 px-8 rounded-full text-sm transition-all transform hover:-translate-y-0.5 shadow-md uppercase tracking-wider"
              >
                BOOK FREE CONSULTATION NOW
              </button>
            </div>
          </div>
        </div>

      </div>
    </section>
  );
}
