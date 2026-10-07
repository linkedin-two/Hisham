import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Quote, Award, ShieldCheck } from "lucide-react";

export default function LeadershipSection() {
  return (
    <section className="py-20 bg-[#F0F4FA] border-y border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Split Screen with /about.png */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center mb-12">
          
          {/* Left Column: Image /about.png */}
          <div className="lg:col-span-5 relative rounded-3xl overflow-hidden shadow-2xl border-4 border-white group">
            <img
              src="/about.png"
              alt="Edzkool Medical Education Journey"
              className="w-full h-[400px] object-cover group-hover:scale-105 transition-transform duration-700"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-[#103C82]/80 via-transparent to-transparent" />
            
            <div className="absolute bottom-6 left-6 right-6 text-white space-y-1">
              <span className="bg-[#F58220] text-white text-[10px] font-black uppercase px-3 py-1 rounded-pill">
                ESTABLISHED 2019
              </span>
              <h4 className="text-lg font-black">Empowering Aspiring Doctors</h4>
              <p className="text-xs text-blue-100 font-medium">
                12+ Consulting Centers Across Russia, Georgia & Uzbekistan
              </p>
            </div>
          </div>

          {/* Right Column: Leadership Quote Card */}
          <div className="lg:col-span-7 bg-gradient-to-r from-[#103C82] to-[#0B2A5D] rounded-3xl p-8 sm:p-10 text-white shadow-xl relative overflow-hidden border-t-4 border-[#F58220] space-y-6">
            
            <div className="inline-flex items-center space-x-2 bg-white/10 border border-white/20 px-4 py-1.5 rounded-pill text-[#F58220] font-extrabold text-xs">
              <Award className="w-4 h-4" />
              <span>{EDZKOOL_DATA.leadership.subtitle}</span>
            </div>

            <h2 className="text-2xl sm:text-3xl font-black text-white leading-tight">
              &ldquo;{EDZKOOL_DATA.company.tagline}&rdquo;
            </h2>

            <div className="relative pl-6 border-l-4 border-[#F58220] space-y-2">
              <Quote className="w-8 h-8 text-[#F58220] opacity-40 absolute -top-4 -left-3" />
              <p className="text-sm sm:text-base text-blue-100 font-medium leading-relaxed italic">
                {EDZKOOL_DATA.leadership.quote}
              </p>
            </div>

            <p className="text-xs sm:text-sm text-blue-200 font-medium leading-relaxed">
              {EDZKOOL_DATA.leadership.body}
            </p>

            <div className="pt-2 border-t border-white/10 flex items-center justify-between">
              <div>
                <span className="font-extrabold text-white block text-sm">
                  {EDZKOOL_DATA.leadership.author}
                </span>
                <span className="text-xs text-[#F58220] font-semibold">
                  {EDZKOOL_DATA.leadership.role}
                </span>
              </div>
              <span className="text-xs font-black text-white bg-white/10 px-3 py-1.5 rounded-pill">
                300+ ALUMNI DOCTORS
              </span>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
