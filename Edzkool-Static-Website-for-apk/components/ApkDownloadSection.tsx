"use client";

import React, { useState } from "react";
import { Download, ShieldCheck, Sparkles, CheckCircle2 } from "lucide-react";

export default function ApkDownloadSection() {
  const [downloadStarted, setDownloadStarted] = useState(false);

  const handleDownload = () => {
    // Slight delay so the browser natively dispatches the download before any UI state update
    setTimeout(() => {
      setDownloadStarted(true);
    }, 250);

    setTimeout(() => {
      setDownloadStarted(false);
    }, 9000);
  };

  return (
    <section id="download-apk" className="py-16 md:py-24 bg-[#0B2A5B] text-white relative overflow-hidden">
      {/* Decorative background ambient glows */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-[#FD9202]/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-[#144787]/30 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-[1200px] mx-auto px-6 relative z-10">
        {/* Main card container */}
        <div className="bg-[#12386E]/80 backdrop-blur-md rounded-[32px] p-8 sm:p-12 lg:p-16 border border-white/10 shadow-2xl grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-12 items-center">
          
          {/* Left Column: App Information & Perks */}
          <div className="lg:col-span-7 flex flex-col gap-5 text-left">
            <div className="inline-flex items-center gap-2 self-start bg-white/10 text-white text-xs font-bold px-4 py-1.5 rounded-full border border-white/15 tracking-wider uppercase shadow-xs">
              <Sparkles className="w-3.5 h-3.5 text-[#FD9202]" />
              <span>Official Android App</span>
            </div>

            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] font-black text-white leading-tight tracking-tight">
              Download the <span className="text-[#FD9202]">Edzkool</span> Mobile App
            </h2>

            <p className="text-base sm:text-[17px] text-[#D6E3F6] font-normal leading-relaxed max-w-xl">
              Get instant access to live 1-on-1 coaching classes, interactive doubt clearing, study notes, question banks, and learning progress on your Android smartphone.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5 pt-2">
              <div className="flex items-center gap-2.5 text-sm font-medium text-white/95">
                <CheckCircle2 className="w-4 h-4 text-[#FD9202] shrink-0" />
                <span>Live 1-on-1 Classes & Doubts</span>
              </div>
              <div className="flex items-center gap-2.5 text-sm font-medium text-white/95">
                <CheckCircle2 className="w-4 h-4 text-[#FD9202] shrink-0" />
                <span>Curated Notes & Worksheets</span>
              </div>
              <div className="flex items-center gap-2.5 text-sm font-medium text-white/95">
                <CheckCircle2 className="w-4 h-4 text-[#FD9202] shrink-0" />
                <span>Real-Time Progress Updates</span>
              </div>
              <div className="flex items-center gap-2.5 text-sm font-medium text-white/95">
                <CheckCircle2 className="w-4 h-4 text-[#FD9202] shrink-0" />
                <span>100% Free & Safe APK</span>
              </div>
            </div>
          </div>

          {/* Right Column: Download Card */}
          <div className="lg:col-span-5 bg-white text-[#1B2A44] rounded-[28px] p-8 sm:p-10 shadow-2xl flex flex-col items-center text-center">
            
            {/* Android Icon Header */}
            <div className="w-16 h-16 rounded-full bg-[#EAF1FB] text-[#144787] flex items-center justify-center mx-auto mb-4 shadow-inner">
              <svg className="w-9 h-9 fill-[#144787]" viewBox="0 0 24 24">
                <path d="M6 18c0 .55.45 1 1 1h1v3c0 .55.45 1 1 1s1-.45 1-1v-3h4v3c0 .55.45 1 1 1s1-.45 1-1v-3h1c.55 0 1-.45 1-1V8H6v10zM3.5 8C2.67 8 2 8.67 2 9.5v7c0 .83.67 1.5 1.5 1.5S5 17.33 5 16.5v-7C5 8.67 4.33 8 3.5 8zm17 0c-.83 0-1.5.67-1.5 1.5v7c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5v-7c0-.83-.67-1.5-1.5-1.5zm-4.97-4.84l1.17-1.17c.16-.16.16-.42 0-.58-.16-.16-.42-.16-.58 0l-1.35 1.35C13.84 2.27 12.96 2 12 2c-.96 0-1.84.27-2.77.76L7.88 1.41c-.16-.16-.42-.16-.58 0-.16.16-.16.42 0 .58l1.17 1.17C6.73 4.39 5.5 6.06 5.5 8h13c0-1.94-1.23-3.61-2.97-4.84zM9 5.5c-.41 0-.75-.34-.75-.75s.34-.75.75-.75.75.34.75.75-.34.75-.75.75zm6 0c-.41 0-.75-.34-.75-.75s.34-.75.75-.75.75.34.75.75-.34.75-.75.75z"/>
              </svg>
            </div>

            <h3 className="font-serif text-2xl font-bold text-[#0B2A5B]">
              Edzkool Student App
            </h3>
            <p className="text-xs sm:text-sm text-gray-500 font-medium mt-1 mb-6">
              Version 2.4.0 • 86.9 MB • Android 8.0+
            </p>

            {/* Direct APK Download Link Button */}
            <div className="w-full space-y-3">
              <a
                href="/edzkool-app.apk"
                download="Edzkool_Student_App.apk"
                target="_self"
                rel="noopener noreferrer"
                onClick={handleDownload}
                className="w-full bg-gradient-to-r from-[#F58220] to-[#FD9202] hover:brightness-105 active:scale-[0.98] text-white font-bold py-4 px-6 rounded-full text-base tracking-wider uppercase transition-all transform hover:-translate-y-0.5 shadow-md flex items-center justify-center gap-2.5 cursor-pointer select-none"
              >
                <Download className="w-5 h-5" />
                <span>DOWNLOAD THE APK</span>
              </a>

              {downloadStarted && (
                <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold py-2.5 px-4 rounded-xl text-center flex flex-col gap-1 transition-all">
                  <span>✓ APK Download Started! Check your browser downloads folder.</span>
                  <span className="text-[11px] text-emerald-700 font-normal">
                    If it didn&apos;t start automatically,{" "}
                    <a
                      href="/edzkool-app.apk"
                      download="Edzkool_Student_App.apk"
                      className="underline font-bold text-emerald-900 hover:text-emerald-950"
                    >
                      click here to retry
                    </a>.
                  </span>
                </div>
              )}
            </div>

            <div className="flex items-center justify-center gap-1.5 text-xs text-gray-500 font-medium pt-5 mt-2 border-t border-gray-100 w-full">
              <ShieldCheck className="w-4 h-4 text-[#FD9202]" />
              <span>Verified Clean APK • No Malware Guarantee</span>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
}
