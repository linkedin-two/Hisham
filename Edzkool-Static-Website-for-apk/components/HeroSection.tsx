"use client";
import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Sparkles, ArrowRight, Play, CheckCircle2 } from "lucide-react";

interface HeroSectionProps {
  onOpenModal: () => void;
}

export default function HeroSection({ onOpenModal }: HeroSectionProps) {
  return (
    <section className="relative bg-white pt-12 pb-20 lg:pt-20 lg:pb-28 overflow-hidden">
      {/* Decorative background elements */}
      <div className="absolute top-0 right-0 -mr-20 -mt-20 w-96 h-96 rounded-full bg-[#103C82]/5 blur-3xl"></div>
      <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 rounded-full bg-[#F58220]/5 blur-3xl"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          
          {/* Left Content */}
          <div className="space-y-8 animate-fade-in-up">
            <div className="inline-flex items-center space-x-2 bg-[#F0F4FA] border border-[#103C82]/10 px-4 py-2 rounded-pill shadow-xs">
              <Sparkles className="w-4 h-4 text-[#F58220]" />
              <span className="text-xs font-black text-[#103C82] tracking-wide uppercase">
                {EDZKOOL_DATA.company.tagline}
              </span>
            </div>
            
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-gray-900 leading-[1.1] tracking-tight">
              Premium <span className="text-[#103C82] relative whitespace-nowrap">
                1-on-1 Online
                <svg className="absolute -bottom-2 left-0 w-full h-3 text-[#F58220]/30" viewBox="0 0 100 10" preserveAspectRatio="none">
                  <path d="M0 5 Q 50 10 100 5" stroke="currentColor" strokeWidth="4" fill="transparent"/>
                </svg>
              </span> <br />
              Coaching Center.
            </h1>
            
            <p className="text-lg sm:text-xl text-gray-600 font-medium leading-relaxed max-w-lg">
              {EDZKOOL_DATA.company.heroSubtitle}
            </p>

            <div className="flex flex-col sm:flex-row gap-4 pt-4">
              <button 
                onClick={onOpenModal}
                className="bg-[#103C82] text-white px-8 py-4 rounded-pill font-black text-lg hover:bg-[#0B2A5D] transition-all transform hover:-translate-y-1 shadow-lg shadow-[#103C82]/30 border-b-4 border-[#F58220] flex items-center justify-center space-x-2 group"
              >
                <span>Book a Free Demo</span>
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </button>
              
              <a 
                href="#programs" 
                className="bg-white text-[#103C82] border-2 border-gray-200 hover:border-[#103C82] px-8 py-4 rounded-pill font-black text-lg transition-all flex items-center justify-center space-x-2"
              >
                <Play className="w-5 h-5 fill-current" />
                <span>Explore Programs</span>
              </a>
            </div>

            <div className="grid grid-cols-2 gap-4 pt-6 border-t border-gray-100">
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-5 h-5 text-[#F58220]" />
                <span className="text-sm font-bold text-gray-700">Expert Tutors</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-5 h-5 text-[#F58220]" />
                <span className="text-sm font-bold text-gray-700">Flexible Timings</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-5 h-5 text-[#F58220]" />
                <span className="text-sm font-bold text-gray-700">100% Online</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle2 className="w-5 h-5 text-[#F58220]" />
                <span className="text-sm font-bold text-gray-700">Personalized Pace</span>
              </div>
            </div>
          </div>

          {/* Right Image/Graphic */}
          <div className="relative lg:ml-auto animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
            <div className="relative rounded-[2.5rem] bg-gradient-to-tr from-[#103C82] to-[#1c55b3] p-1 shadow-2xl transform rotate-2 hover:rotate-0 transition-transform duration-500">
              <img 
                src="/Hisham/Hisham/10.png" 
                alt="Online Coaching Session" 
                className="rounded-[2.4rem] object-cover w-full h-auto"
              />
              
              {/* Floating Badge 1 */}
              <div className="absolute -left-6 top-12 bg-white p-4 rounded-2xl shadow-xl border border-gray-100 flex items-center space-x-4 animate-bounce-slow">
                <div className="bg-[#e6f4ea] w-12 h-12 rounded-full flex items-center justify-center">
                  <span className="text-2xl">🎓</span>
                </div>
                <div>
                  <div className="text-xs font-bold text-gray-400 uppercase tracking-wider">Students</div>
                  <div className="font-black text-gray-900 text-lg">{EDZKOOL_DATA.company.studentsMentored}</div>
                </div>
              </div>

              {/* Floating Badge 2 */}
              <div className="absolute -right-6 bottom-12 bg-white p-4 rounded-2xl shadow-xl border border-gray-100 flex items-center space-x-4 animate-bounce-slow" style={{ animationDelay: '1s' }}>
                <div className="bg-[#fff4e6] w-12 h-12 rounded-full flex items-center justify-center">
                  <span className="text-2xl">⭐</span>
                </div>
                <div>
                  <div className="text-xs font-bold text-gray-400 uppercase tracking-wider">Success Rate</div>
                  <div className="font-black text-gray-900 text-lg">{EDZKOOL_DATA.company.successRate}</div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
