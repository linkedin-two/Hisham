import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Quote, Award, ShieldCheck } from "lucide-react";

export default function LeadershipSection() {
  return (
    <section id="about" className="py-20 bg-slate-50/60">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Split Screen with /about.png */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
          
          {/* Left Column: Image /about.png */}
          <div className="lg:col-span-5 relative rounded-3xl overflow-hidden shadow-lg border border-gray-100 flex flex-col justify-end min-h-[380px]">
            <img
              src="/about.png"
              alt="Edzkool Medical Education Journey"
              className="absolute inset-0 w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-[#0B254E]/90 via-[#0B254E]/20 to-transparent" />
            
            <div className="relative z-10 p-6 sm:p-8 text-white space-y-1.5">
              <span className="bg-[#F58220] text-white text-[11px] font-bold uppercase px-3 py-1 rounded-full inline-block shadow-xs">
                ESTABLISHED 2019
              </span>
              <h4 className="text-xl font-bold">Empowering Aspiring Doctors</h4>
              <p className="text-xs text-blue-100 font-medium">
                12+ Consulting Centers Across Russia, Georgia & Uzbekistan
              </p>
            </div>
          </div>

          {/* Right Column: Leadership Quote Card */}
          <div className="lg:col-span-7 bg-[#0D264A] rounded-3xl p-8 sm:p-10 text-white shadow-xl border border-blue-900/50 flex flex-col justify-between space-y-6">
            
            <div className="space-y-4">
              <div className="inline-flex items-center space-x-2 bg-[#F58220]/15 border border-[#F58220]/30 px-3.5 py-1 rounded-full text-[#F58220] font-bold text-xs uppercase tracking-wider">
                <Award className="w-3.5 h-3.5" />
                <span>Our Philosophy</span>
              </div>

              <h2 className="text-2xl sm:text-3xl font-extrabold text-white leading-tight">
                &ldquo;Empowering Minds Through Personalized Learning&rdquo;
              </h2>

              <div className="relative pl-5 border-l-2 border-[#F58220] space-y-2 py-1">
                <Quote className="w-6 h-6 text-[#F58220] opacity-40 absolute -top-3 -left-2" />
                <p className="text-sm sm:text-base text-blue-100/90 font-normal leading-relaxed italic">
                  &ldquo;Every student has a unique pace and potential. Finding the right coach turns potential into peak performance and lifelong confidence.&rdquo;
                </p>
              </div>

              <p className="text-xs sm:text-sm text-blue-200/80 font-normal leading-relaxed">
                We believe that true education goes beyond textbooks. Our mission is to democratize high-caliber 1-on-1 tutoring, making world-class mentorship accessible, flexible, and affordable for ambitious students everywhere.
              </p>
            </div>

            <div className="pt-4 border-t border-white/10 flex items-center justify-between">
              <div>
                <span className="font-extrabold text-white block text-sm sm:text-base">
                  Dr. Hisham K.
                </span>
                <span className="text-xs text-[#F58220] font-semibold">
                  Founder & Chief Academic Director
                </span>
              </div>
              <span className="text-xs font-bold text-blue-100 bg-white/10 px-3.5 py-1.5 rounded-full border border-white/10">
                300+ ALUMNI DOCTORS
              </span>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
