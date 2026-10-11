"use client";
import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Sparkles, ArrowRight, CheckCircle2, Smartphone, Star, GraduationCap } from "lucide-react";

interface HeroSectionProps {
  onOpenModal: () => void;
}

export default function HeroSection({ onOpenModal }: HeroSectionProps) {
  return (
    <section className="relative bg-white pt-10 pb-16 lg:pt-16 lg:pb-24 overflow-hidden">
      {/* Decorative background glows */}
      <div className="absolute top-0 right-0 -mr-20 -mt-20 w-96 h-96 rounded-full bg-[#103C82]/5 blur-3xl pointer-events-none"></div>
      <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 rounded-full bg-[#F58220]/5 blur-3xl pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          
          {/* Left Content */}
          <div className="space-y-6">
            <div className="inline-flex items-center space-x-2 bg-[#F0F4FA] border border-[#103C82]/15 px-3.5 py-1.5 rounded-full shadow-xs">
              <span className="w-2 h-2 rounded-full bg-[#103C82] animate-pulse"></span>
              <span className="text-xs font-bold text-[#103C82] tracking-wide">
                Trusted by 10,000+ Students Worldwide
              </span>
            </div>
            
            <h1 className="text-4xl sm:text-5xl lg:text-[3.5rem] font-extrabold text-gray-900 leading-[1.15] tracking-tight">
              Premium <br />
              <span className="text-[#103C82]">1-on-1 Online</span> <br />
              Coaching Center.
            </h1>
            
            <p className="text-base sm:text-lg text-gray-600 font-normal leading-relaxed max-w-lg">
              Empowering students across the globe with personalized academic coaching, language mastery, and guaranteed medical abroad pathways.
            </p>

            <div className="flex flex-col sm:flex-row gap-3 pt-2">
              <a 
                href="#programs"
                className="bg-[#103C82] hover:bg-[#0B2A5D] text-white px-7 py-3.5 rounded-full font-bold text-base transition-all transform hover:-translate-y-0.5 shadow-md flex items-center justify-center space-x-2 group"
              >
                <span>Explore Programs</span>
                <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </a>
              
              <a 
                href="#download-apk" 
                className="bg-white hover:bg-gray-50 text-[#103C82] border border-gray-300 px-7 py-3.5 rounded-full font-bold text-base transition-all flex items-center justify-center space-x-2 shadow-xs"
              >
                <Smartphone className="w-4 h-4 text-[#F58220]" />
                <span>Download Mobile App</span>
              </a>
            </div>

            <div className="grid grid-cols-2 gap-x-6 gap-y-3 pt-4 border-t border-gray-100 max-w-md">
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span className="text-sm font-semibold text-gray-700">Expert Tutors</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span className="text-sm font-semibold text-gray-700">Flexible Timings</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span className="text-sm font-semibold text-gray-700">100% Online</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span className="text-sm font-semibold text-gray-700">Personalized Pace</span>
              </div>
            </div>
          </div>

          {/* Right Image/Graphic */}
          <div className="relative lg:ml-auto w-full max-w-lg mx-auto">
            <div className="relative rounded-3xl bg-gradient-to-tr from-[#EBF3FC] to-white p-3 shadow-xl border border-blue-50">
              <img 
                src="/10.png" 
                alt="Online Coaching Session" 
                className="rounded-2xl object-cover w-full h-auto shadow-sm"
              />
              
              {/* Floating Badge 1 - Rating */}
              <div className="absolute -left-4 top-8 bg-white px-4 py-2.5 rounded-2xl shadow-lg border border-gray-100 flex items-center space-x-3">
                <div className="bg-[#FEF6E9] p-2 rounded-xl text-[#F58220]">
                  <Star className="w-5 h-5 fill-current" />
                </div>
                <div>
                  <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider">Top Rated</div>
                  <div className="font-extrabold text-gray-900 text-sm">4.9 / 5 Stars</div>
                </div>
              </div>

              {/* Floating Badge 2 - Students */}
              <div className="absolute -right-4 bottom-8 bg-white px-4 py-2.5 rounded-2xl shadow-lg border border-gray-100 flex items-center space-x-3">
                <div className="bg-[#EEF4FD] p-2 rounded-xl text-[#103C82]">
                  <GraduationCap className="w-5 h-5" />
                </div>
                <div>
                  <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider">Students</div>
                  <div className="font-extrabold text-gray-900 text-sm">1,000+ Enrolled</div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
