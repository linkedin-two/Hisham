import React from "react";
import Link from "next/link";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { MapPin, Mail, Phone } from "lucide-react";

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white pt-16 pb-8 border-t border-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 pb-12 border-b border-gray-800">
          
          {/* Column 1: Official Logo & Mission */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center space-x-3">
              <img
                src="/logo.png"
                alt="Edzkool Logo"
                className="h-11 w-auto object-contain rounded-xl bg-white p-1 shadow-sm"
              />
              <span className="font-black text-2xl tracking-tight text-white">
                <span className="text-white">edz</span>
                <span className="text-[#F58220]">k</span>
                <span className="text-white">ool</span>{" "}
                <span className="text-[#F58220] text-xs px-2 py-0.5 rounded-pill bg-white/10">EDU</span>
              </span>
            </div>

            <p className="text-gray-400 text-xs sm:text-sm font-medium leading-relaxed max-w-sm">
              &ldquo;{EDZKOOL_DATA.company.tagline}&rdquo; — {EDZKOOL_DATA.company.name} is India&apos;s leading medical admission consultancy helping students achieve their academic goals through personalized learning.
            </p>

            <div className="space-y-2 pt-2 text-xs font-semibold text-gray-300">
              <div className="flex items-center space-x-2">
                <Mail className="w-4 h-4 text-[#F58220]" />
                <span>{EDZKOOL_DATA.company.email}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Phone className="w-4 h-4 text-[#F58220]" />
                <span>{EDZKOOL_DATA.company.phone}</span>
              </div>
              <div className="flex items-start space-x-2">
                <MapPin className="w-4 h-4 text-[#F58220] shrink-0 mt-0.5" />
                <span>{EDZKOOL_DATA.company.headOffice}</span>
              </div>
            </div>
          </div>

          {/* Column 2: Destinations */}
          <div className="space-y-3">
            <h4 className="font-extrabold text-sm text-[#F58220] uppercase tracking-wider">
              Our Programs
            </h4>
            <ul className="space-y-2 text-xs text-gray-400 font-medium">
              <li><Link href="#programs" className="hover:text-white transition-colors">IELTS Coaching</Link></li>
              <li><Link href="#programs" className="hover:text-white transition-colors">Grades 1-10 Tuition</Link></li>
              <li><Link href="#programs" className="hover:text-white transition-colors">Coding for Kids</Link></li>
              <li><Link href="#programs" className="hover:text-white transition-colors">Spoken English</Link></li>
              <li><Link href="#programs" className="hover:text-white transition-colors">Competitive Exams</Link></li>
            </ul>
          </div>

          {/* Column 3: Services */}
          <div className="space-y-3">
            <h4 className="font-extrabold text-sm text-[#F58220] uppercase tracking-wider">
              Our Services
            </h4>
            <ul className="space-y-2 text-xs text-gray-400 font-medium">
              <li><Link href="#services" className="hover:text-white transition-colors">1-on-1 Mentorship</Link></li>
              <li><Link href="#services" className="hover:text-white transition-colors">Interactive Live Classes</Link></li>
              <li><Link href="#services" className="hover:text-white transition-colors">Mock Exams FMGE Coaching Analysis</Link></li>
              <li><Link href="#services" className="hover:text-white transition-colors">Doubt Clearing Sessions</Link></li>
              <li><Link href="/blog" className="hover:text-white transition-colors">Medical Blog</Link></li>
            </ul>
          </div>

          {/* Column 4: Global Presence */}
          <div className="space-y-3">
            <h4 className="font-extrabold text-sm text-[#F58220] uppercase tracking-wider">
              Global Presence
            </h4>
            <p className="text-xs text-gray-400 font-medium leading-relaxed">
              12+ Consulting centers worldwide with direct support offices in:
            </p>
            <div className="flex flex-wrap gap-2 pt-1">
              {EDZKOOL_DATA.company.globalPresence.map((c, i) => (
                <span key={i} className="bg-gray-800 text-gray-300 text-[11px] font-bold px-2.5 py-1 rounded-pill border border-gray-700">
                  📍 {c}
                </span>
              ))}
            </div>
          </div>

        </div>

        {/* Bottom Copyright */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-gray-500 font-medium space-y-4 sm:space-y-0">
          <div>
            &copy; {new Date().getFullYear()} {EDZKOOL_DATA.company.name}. All rights reserved.
          </div>
          <div className="flex items-center space-x-6">
            <a href="#" className="hover:text-gray-300">Privacy Policy</a>
            <a href="#" className="hover:text-gray-300">Terms of Service</a>
            <a href="#" className="hover:text-gray-300">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
