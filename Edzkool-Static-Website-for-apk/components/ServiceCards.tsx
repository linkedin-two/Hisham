import React from "react";
import { EDZKOOL_DATA, ServiceItem } from "@/data/edzkool-data";
import { CheckCircle2, ArrowRight } from "lucide-react";

// Local SVG icon paths for each service index
const SERVICE_ICONS = [
  "/image (1).svg",
  "/image (2).svg",
  "/image (3).svg",
  "/image (4).svg",
  "/image (5).svg",
  "/image (6).svg",
];

interface ServiceCardsProps {
  onOpenModal: () => void;
}

const MEDICAL_SERVICES = [
  {
    step: "Step 01",
    title: "Initial Counselling",
    description: "Free 1-on-1 profile evaluation to find the ideal country, budget, and university match.",
    icon: "/image (1).svg",
  },
  {
    step: "Step 02",
    title: "University Selection",
    description: "Direct admission in NMC & WHO recognized government medical universities.",
    icon: "/image (2).svg",
  },
  {
    step: "Step 03",
    title: "Visa & Documentation",
    description: "100% visa assistance, MEA apostille, document translation, and invitation letter.",
    icon: "/image (3).svg",
  },
  {
    step: "Step 04",
    title: "Post-Arrival Assistance",
    description: "Airport pickup, hostel allocation, local SIM card, bank account, and Indian food mess.",
    icon: "/image (4).svg",
  },
];

export default function ServiceCards({ onOpenModal }: ServiceCardsProps) {
  return (
    <section id="medical-services" className="py-20 bg-slate-50/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-14">
          <div className="inline-block bg-[#FFF3E8] text-[#F58220] font-bold text-xs px-3.5 py-1 rounded-full uppercase tracking-wider mb-2.5 border border-[#F58220]/20">
            Comprehensive Support
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-[#0B254E] tracking-tight">
            End-to-End Medical Admission Services
          </h2>
          <p className="text-sm sm:text-base text-gray-500 font-normal mt-2.5">
            From university selection to your first day in clinical rotations, we guide you every step of the way.
          </p>
        </div>

        {/* 4 Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {MEDICAL_SERVICES.map((item, idx) => (
            <div
              key={idx}
              className="bg-white rounded-2xl p-6 border border-gray-100/90 shadow-xs hover:shadow-md hover:-translate-y-1 transition-all duration-300 flex flex-col justify-between"
            >
              <div>
                <div className="flex items-center justify-between mb-5">
                  <div className="w-12 h-12 rounded-xl bg-blue-50/80 flex items-center justify-center p-2.5">
                    <img src={item.icon} alt={item.title} className="w-7 h-7 object-contain" />
                  </div>
                  <span className="text-[11px] font-semibold text-[#103C82] bg-blue-50 px-2.5 py-0.5 rounded-full">
                    {item.step}
                  </span>
                </div>

                <h3 className="text-lg font-bold text-[#0B254E] mb-2">
                  {item.title}
                </h3>

                <p className="text-xs sm:text-sm text-gray-500 font-normal leading-relaxed mb-6">
                  {item.description}
                </p>
              </div>

              <button
                onClick={onOpenModal}
                className="w-full bg-[#F3F6FB] hover:bg-[#103C82] hover:text-white text-[#103C82] font-semibold py-2.5 rounded-full text-xs transition-colors flex items-center justify-center space-x-1.5"
              >
                <span>Learn More</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
}
