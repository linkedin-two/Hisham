"use client";
import React, { useState } from "react";
import Link from "next/link";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { ArrowRight, BookOpen } from "lucide-react";

interface CountryTabsProps {
  onOpenModal: () => void;
}

export default function CountryTabs({ onOpenModal }: CountryTabsProps) {
  const [activeTab, setActiveTab] = useState(EDZKOOL_DATA.programs[0].id);

  const activeProgram = EDZKOOL_DATA.programs.find((p) => p.id === activeTab);

  return (
    <section id="programs" className="py-20 bg-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center mb-12 space-y-3">
          <h2 className="text-3xl md:text-4xl font-extrabold text-gray-900 tracking-tight">
            Our <span className="text-[#103C82]">Coaching Programs</span>
          </h2>
          <p className="text-gray-500 font-normal max-w-2xl mx-auto text-base">
            Explore specialized 1-on-1 online coaching tracks tailored to your academic and career goals.
          </p>
        </div>

        <div className="flex flex-wrap justify-center gap-2.5 mb-10">
          {EDZKOOL_DATA.programs.map((prog) => (
            <button
              key={prog.id}
              onClick={() => setActiveTab(prog.id)}
              className={`px-5 py-2.5 rounded-full text-sm font-semibold transition-all ${
                activeTab === prog.id
                  ? "bg-[#103C82] text-white shadow-sm"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200 border border-transparent"
              }`}
            >
              {prog.name}
            </button>
          ))}
        </div>

        {activeProgram && (
          <div className="bg-slate-50/70 rounded-3xl p-6 lg:p-10 border border-gray-200/80 flex flex-col lg:flex-row gap-10 items-center">
            <div className="lg:w-1/2 relative w-full">
              <img
                src={activeProgram.image}
                alt={activeProgram.name}
                className="rounded-2xl w-full h-[360px] object-cover shadow-sm"
              />
              <div className="absolute top-4 left-4 bg-white/95 backdrop-blur-sm px-3.5 py-1.5 rounded-full shadow-xs flex items-center space-x-2 border border-gray-100">
                <BookOpen className="w-4 h-4 text-[#103C82]" />
                <span className="font-bold text-[#103C82] text-xs">Top Rated</span>
              </div>
            </div>

            <div className="lg:w-1/2 space-y-6 w-full">
              <div>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-[#0B254E] mb-2.5">
                  {activeProgram.name}
                </h3>
                <p className="text-gray-600 font-normal leading-relaxed text-sm sm:text-base">
                  {activeProgram.description}
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="bg-white p-3.5 rounded-xl border border-gray-100">
                  <span className="block text-[11px] font-bold text-gray-400 uppercase tracking-wider mb-0.5">Duration</span>
                  <span className="font-extrabold text-gray-800 text-sm sm:text-base">{activeProgram.duration}</span>
                </div>
                <div className="bg-white p-3.5 rounded-xl border border-gray-100">
                  <span className="block text-[11px] font-bold text-gray-400 uppercase tracking-wider mb-0.5">Mode</span>
                  <span className="font-extrabold text-gray-800 text-sm sm:text-base">{activeProgram.mode}</span>
                </div>
              </div>

              <div>
                <h4 className="font-bold text-gray-900 mb-2.5 text-sm uppercase tracking-wider">Program Features:</h4>
                <ul className="space-y-2">
                  {activeProgram.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start space-x-2.5 text-sm font-medium text-gray-700">
                      <div className="w-1.5 h-1.5 rounded-full bg-[#F58220] mt-2 shrink-0"></div>
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="flex flex-col sm:flex-row gap-3 pt-3">
                <button
                  onClick={onOpenModal}
                  className="flex-1 bg-white border border-[#103C82] text-[#103C82] hover:bg-gray-50 py-3 rounded-full font-bold text-sm text-center transition-colors flex items-center justify-center space-x-2"
                >
                  <span>View Syllabus</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
                <button
                  onClick={onOpenModal}
                  className="flex-1 bg-[#103C82] hover:bg-[#0B2A5D] text-white py-3 rounded-full font-bold text-sm shadow-sm transition-colors text-center"
                >
                  Enrol Now
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
