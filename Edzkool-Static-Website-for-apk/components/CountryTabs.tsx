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
    <section id="destinations" className="py-24 bg-gray-50 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center mb-16 space-y-4">
          <h2 className="text-4xl md:text-5xl font-black text-gray-900 tracking-tight">
            Our <span className="text-[#103C82]">Coaching Programs</span>
          </h2>
          <p className="text-gray-500 font-medium max-w-2xl mx-auto text-lg">
            Explore our specialized 1-on-1 online coaching programs designed for academic excellence.
          </p>
        </div>

        <div className="flex flex-wrap justify-center gap-3 mb-12">
          {EDZKOOL_DATA.programs.map((prog) => (
            <button
              key={prog.id}
              onClick={() => setActiveTab(prog.id)}
              className={`px-6 py-3 rounded-pill text-sm font-bold transition-all shadow-sm ${
                activeTab === prog.id
                  ? "bg-[#103C82] text-white shadow-md scale-105"
                  : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"
              }`}
            >
              {prog.name}
            </button>
          ))}
        </div>

        {activeProgram && (
          <div className="bg-white rounded-3xl p-6 lg:p-10 shadow-bright border border-gray-100 flex flex-col lg:flex-row gap-10 items-center animate-fade-in-up">
            <div className="lg:w-1/2 relative group w-full">
              <div className="absolute inset-0 bg-gradient-to-tr from-[#103C82]/20 to-[#F58220]/20 rounded-2xl transform rotate-2 group-hover:rotate-4 transition-transform duration-500"></div>
              <img
                src={activeProgram.image}
                alt={activeProgram.name}
                className="relative rounded-2xl w-full h-[400px] object-cover shadow-lg transform -rotate-1 group-hover:rotate-0 transition-transform duration-500"
              />
              <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-sm px-4 py-2 rounded-xl shadow-sm flex items-center space-x-2">
                <BookOpen className="w-5 h-5 text-[#103C82]" />
                <span className="font-extrabold text-[#103C82] text-sm">Top Rated</span>
              </div>
            </div>

            <div className="lg:w-1/2 space-y-8 w-full">
              <div>
                <h3 className="text-3xl font-black text-gray-900 mb-3">
                  {activeProgram.name}
                </h3>
                <p className="text-gray-600 font-medium leading-relaxed">
                  {activeProgram.description}
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="bg-gray-50 p-4 rounded-xl border border-gray-100">
                  <span className="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-1">Duration</span>
                  <span className="font-extrabold text-gray-800">{activeProgram.duration}</span>
                </div>
                <div className="bg-gray-50 p-4 rounded-xl border border-gray-100">
                  <span className="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-1">Mode</span>
                  <span className="font-extrabold text-gray-800">{activeProgram.mode}</span>
                </div>
              </div>

              <div>
                <h4 className="font-extrabold text-gray-900 mb-3">Program Features:</h4>
                <ul className="space-y-2">
                  {activeProgram.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start space-x-3 text-sm font-bold text-gray-600">
                      <div className="w-1.5 h-1.5 rounded-full bg-[#F58220] mt-1.5 shrink-0"></div>
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="flex flex-col sm:flex-row gap-4 pt-4">
                <Link
                  href={`/programs/${activeProgram.slug}`}
                  className="flex-1 bg-white border-2 border-[#103C82] text-[#103C82] hover:bg-gray-50 py-3.5 rounded-pill font-black text-center transition-colors flex items-center justify-center space-x-2"
                >
                  <span>View Details</span>
                  <ArrowRight className="w-4 h-4" />
                </Link>
                <button
                  onClick={onOpenModal}
                  className="flex-1 bg-[#103C82] text-white hover:bg-[#0a2756] py-3.5 rounded-pill font-black shadow-md border-b-2 border-[#F58220] transition-colors"
                >
                  Book a Demo
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
