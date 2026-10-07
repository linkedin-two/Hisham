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

export default function ServiceCards({ onOpenModal }: ServiceCardsProps) {
  return (
    <section id="services" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-block bg-[#FFF3E8] text-[#F58220] font-extrabold text-xs px-4 py-1.5 rounded-pill uppercase tracking-widest mb-3 border border-[#F58220]/20">
            Comprehensive Support
          </div>
          <h2 className="text-3xl sm:text-4xl font-black text-gray-900 tracking-tight">
            End-to-End Medical Admission Services
          </h2>
          <p className="text-base text-gray-600 font-medium mt-3">
            From initial university selection to your first day in clinical rotations, we guide you every step of the way.
          </p>
        </div>

        {/* 6 Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {EDZKOOL_DATA.services.map((item: ServiceItem, idx: number) => {
            const svgIcon = SERVICE_ICONS[idx % SERVICE_ICONS.length];

            return (
              <div
                key={idx}
                className="bg-white rounded-3xl p-8 border border-gray-100 shadow-bright hover:-translate-y-2 transition-all duration-300 flex flex-col justify-between relative overflow-hidden group"
              >
                {/* Top Accent Gradient Border */}
                <div
                  className="absolute top-0 left-0 right-0 h-2"
                  style={{ backgroundColor: "#103C82" }}
                />

                <div>
                  <div className="flex items-center justify-between mb-6">
                    <div
                      className="w-14 h-14 rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110 p-3"
                      style={{ backgroundColor: "#eaf2ff" }}
                    >
                      <img src={svgIcon} alt={item.title} className="w-8 h-8 object-contain" />
                    </div>
                    <span
                      className="text-[10px] font-black uppercase px-3 py-1 rounded-pill"
                      style={{ backgroundColor: "#eaf2ff", color: "#103C82" }}
                    >
                      "Featured"
                    </span>
                  </div>

                  <h3 className="text-xl font-extrabold text-gray-900 mb-3 group-hover:text-[#103C82] transition-colors">
                    {item.title}
                  </h3>

                  <p className="text-sm text-gray-600 font-medium leading-relaxed mb-6">
                    {item.description}
                  </p>

                  {/* No bullets in this version */}
                </div>

                <button
                  onClick={onOpenModal}
                  className="w-full bg-[#F0F4FA] hover:bg-[#103C82] hover:text-white text-[#103C82] font-extrabold py-3 rounded-pill text-xs transition-colors flex items-center justify-center space-x-2"
                >
                  <span>Learn More</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
