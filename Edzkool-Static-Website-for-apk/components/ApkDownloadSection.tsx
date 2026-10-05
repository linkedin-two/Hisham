"use client";

import React, { useState } from "react";
import { Download, ShieldCheck, Smartphone, Sparkles, CheckCircle2 } from "lucide-react";

export default function ApkDownloadSection() {
  const [downloadStarted, setDownloadStarted] = useState(false);

  const handleDownload = (e: React.MouseEvent) => {
    setDownloadStarted(true);
    setTimeout(() => {
      setDownloadStarted(false);
    }, 4000);
  };

  return (
    <section id="download-apk" className="py-16 bg-[#103C82] text-white relative overflow-hidden">
      {/* Background Shapes */}
      <div className="absolute top-0 right-0 w-80 h-80 bg-[#F58220]/20 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-80 h-80 bg-blue-400/10 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="bg-white/10 backdrop-blur-md rounded-3xl p-8 sm:p-12 border border-white/20 grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          
          {/* Left Column: Android Icon & App Info */}
          <div className="lg:col-span-7 space-y-4 text-center lg:text-left">
            <div className="inline-flex items-center space-x-2 bg-[#F58220] text-white text-xs font-black px-3.5 py-1.5 rounded-pill shadow-xs">
              <Sparkles className="w-4 h-4" />
              <span>OFFICIAL ANDROID APP</span>
            </div>

            <h2 className="text-3xl sm:text-4xl font-black text-white leading-tight">
              Download the <span className="text-[#F58220]">Edzkool</span> Mobile App
            </h2>

            <p className="text-sm sm:text-base text-blue-100 font-medium max-w-xl leading-relaxed">
              Get instant access to live NeXT/FMGE coaching classes, Indian doctor mentorship, university study materials, and visa tracking on your Android smartphone.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
              <div className="flex items-center space-x-2 text-xs font-bold text-blue-100">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span>NeXT & FMGE Question Banks</span>
              </div>
              <div className="flex items-center space-x-2 text-xs font-bold text-blue-100">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span>Live Doctor Lectures & Notes</span>
              </div>
              <div className="flex items-center space-x-2 text-xs font-bold text-blue-100">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span>Real-Time Admission Updates</span>
              </div>
              <div className="flex items-center space-x-2 text-xs font-bold text-blue-100">
                <CheckCircle2 className="w-4 h-4 text-[#F58220] shrink-0" />
                <span>100% Free & Safe APK</span>
              </div>
            </div>
          </div>

          {/* Right Column: Download Form / Single Action Button */}
          <div className="lg:col-span-5 bg-white text-gray-900 rounded-2xl p-6 sm:p-8 shadow-2xl border-2 border-[#F58220] text-center space-y-5">
            
            {/* Android Icon Header */}
            <div className="w-16 h-16 rounded-full bg-[#EBF2FD] text-[#103C82] flex items-center justify-center mx-auto shadow-inner">
              {/* Android Robot SVG Icon */}
              <svg className="w-10 h-10 fill-[#103C82]" viewBox="0 0 24 24">
                <path d="M6 18c0 .55.45 1 1 1h1v3c0 .55.45 1 1 1s1-.45 1-1v-3h4v3c0 .55.45 1 1 1s1-.45 1-1v-3h1c.55 0 1-.45 1-1V8H6v10zM3.5 8C2.67 8 2 8.67 2 9.5v7c0 .83.67 1.5 1.5 1.5S5 17.33 5 16.5v-7C5 8.67 4.33 8 3.5 8zm17 0c-.83 0-1.5.67-1.5 1.5v7c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5v-7c0-.83-.67-1.5-1.5-1.5zm-4.97-4.84l1.17-1.17c.16-.16.16-.42 0-.58-.16-.16-.42-.16-.58 0l-1.35 1.35C13.84 2.27 12.96 2 12 2c-.96 0-1.84.27-2.77.76L7.88 1.41c-.16-.16-.42-.16-.58 0-.16.16-.16.42 0 .58l1.17 1.17C6.73 4.39 5.5 6.06 5.5 8h13c0-1.94-1.23-3.61-2.97-4.84zM9 5.5c-.41 0-.75-.34-.75-.75s.34-.75.75-.75.75.34.75.75-.34.75-.75.75zm6 0c-.41 0-.75-.34-.75-.75s.34-.75.75-.75.75.34.75.75-.34.75-.75.75z"/>
              </svg>
            </div>

            <div>
              <h3 className="text-xl font-black text-[#103C82]">Edzkool Student App</h3>
              <p className="text-xs text-gray-500 font-semibold mt-1">
                Version 2.4.0 • 28.5 MB • Android 8.0+
              </p>
            </div>

            {/* Direct APK Download Form Button */}
            <form onSubmit={(e) => e.preventDefault()} className="space-y-3">
              <a
                href="/edzkool-app.apk"
                download="Edzkool_Student_App.apk"
                onClick={handleDownload}
                className="w-full bg-[#F58220] hover:bg-[#D96C0D] text-white font-black py-4 px-6 rounded-pill text-sm transition-all transform hover:scale-105 shadow-lg flex items-center justify-center space-x-3 border-b-2 border-orange-700"
              >
                <Download className="w-5 h-5 animate-bounce" />
                <span>{downloadStarted ? "DOWNLOADING APK..." : "DOWNLOAD THE APK"}</span>
              </a>

              {downloadStarted && (
                <div className="text-xs font-bold text-emerald-600 animate-pulse">
                  ✓ APK Download Started! Check your downloads folder to install.
                </div>
              )}
            </form>

            <div className="flex items-center justify-center space-x-2 text-[11px] text-gray-500 font-semibold pt-2 border-t border-gray-100">
              <ShieldCheck className="w-4 h-4 text-[#F58220]" />
              <span>Verified Clean APK • No Malware Guarantee</span>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
}
