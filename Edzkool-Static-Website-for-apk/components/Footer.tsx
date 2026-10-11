import React from "react";
import Link from "next/link";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { MapPin, Mail, Phone } from "lucide-react";

export default function Footer() {
  return (
    <footer className="bg-[#0A1A30] text-white pt-16 pb-8 border-t border-blue-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 pb-12 border-b border-white/10">
          
          {/* Column 1: Official Logo & Mission */}
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <img
                src="/logo.png"
                alt="Edzkool Logo"
                className="h-10 w-auto object-contain rounded-xl bg-white p-1 shadow-sm"
              />
              <span className="font-extrabold text-2xl tracking-tight text-white">
                <span className="text-white">edz</span>
                <span className="text-[#F58220]">k</span>
                <span className="text-white">ool</span>
              </span>
            </div>

            <p className="text-gray-300/80 text-xs sm:text-sm font-normal leading-relaxed">
              India&apos;s trusted 1-on-1 coaching platform and premier medical admission consultancy, empowering students with personalized learning and verified global pathways.
            </p>

            <div className="space-y-2.5 pt-2 text-xs font-medium text-gray-300">
              <div className="flex items-center space-x-2.5">
                <Phone className="w-4 h-4 text-[#F58220] shrink-0" />
                <a href={`tel:${EDZKOOL_DATA.company.phone}`} className="hover:underline">
                  {EDZKOOL_DATA.company.phone}
                </a>
              </div>
              <div className="flex items-center space-x-2.5">
                <Mail className="w-4 h-4 text-[#F58220] shrink-0" />
                <a href={`mailto:${EDZKOOL_DATA.company.email}`} className="hover:underline">
                  {EDZKOOL_DATA.company.email}
                </a>
              </div>
              <div className="flex items-start space-x-2.5">
                <MapPin className="w-4 h-4 text-[#F58220] shrink-0 mt-0.5" />
                <span>{EDZKOOL_DATA.company.headOffice}</span>
              </div>
            </div>
          </div>

          {/* Column 2: Quick Links */}
          <div className="space-y-3.5">
            <h4 className="font-bold text-sm text-[#F58220] uppercase tracking-wider">
              Quick Links
            </h4>
            <ul className="space-y-2 text-xs sm:text-sm text-gray-300/80 font-normal">
              <li><Link href="/" className="hover:text-white transition-colors">Home</Link></li>
              <li><Link href="/#programs" className="hover:text-white transition-colors">Coaching Programs</Link></li>
              <li><Link href="/#medical-services" className="hover:text-white transition-colors">Medical Abroad</Link></li>
              <li><Link href="/#comparison" className="hover:text-white transition-colors">Why Edzkool</Link></li>
              <li><Link href="/#testimonials" className="hover:text-white transition-colors">Testimonials</Link></li>
              <li><Link href="/#faq" className="hover:text-white transition-colors">Frequently Asked Questions</Link></li>
            </ul>
          </div>

          {/* Column 3: Coaching & Admission Programs */}
          <div className="space-y-3.5">
            <h4 className="font-bold text-sm text-[#F58220] uppercase tracking-wider">
              Our Programs
            </h4>
            <ul className="space-y-2 text-xs sm:text-sm text-gray-300/80 font-normal">
              <li><Link href="/#programs" className="hover:text-white transition-colors">IELTS Preparation Track</Link></li>
              <li><Link href="/#medical-services" className="hover:text-white transition-colors">MBBS in Russia & Georgia</Link></li>
              <li><Link href="/#programs" className="hover:text-white transition-colors">Spoken English Mastery</Link></li>
              <li><Link href="/#programs" className="hover:text-white transition-colors">Grade 1-10 Foundation Tuition</Link></li>
              <li><Link href="/#download-apk" className="hover:text-white transition-colors">NeXT & FMGE Exam Preparation</Link></li>
            </ul>
          </div>

          {/* Column 4: Mobile App & Global Accreditation */}
          <div className="space-y-3.5">
            <h4 className="font-bold text-sm text-[#F58220] uppercase tracking-wider">
              Mobile App & Accreditations
            </h4>
            <p className="text-xs sm:text-sm text-gray-300/80 font-normal leading-relaxed">
              Download our official student mobile app for instant lecture notes, question banks, and visa updates.
            </p>
            <div className="pt-1">
              <a
                href="/edzkool-app.apk"
                download="Edzkool_Student_App.apk"
                className="inline-flex items-center space-x-2 bg-[#F58220] hover:bg-[#E07310] text-white px-4 py-2.5 rounded-full text-xs font-bold transition-all shadow-sm"
              >
                <span>Download Android APK</span>
                <span>↓</span>
              </a>
            </div>
            <div className="pt-2 text-[11px] text-gray-400 font-medium">
              ✓ 100% NMC & WHO Compliant Guidance
            </div>
          </div>

        </div>

        {/* Bottom Copyright */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-gray-400 font-normal space-y-4 sm:space-y-0">
          <div>
            &copy; {new Date().getFullYear()} {EDZKOOL_DATA.company.name}. All rights reserved.
          </div>
          <div className="flex items-center space-x-6">
            <a href="#" className="hover:text-gray-200 transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-gray-200 transition-colors">Terms of Service</a>
            <a href={`tel:${EDZKOOL_DATA.company.phone}`} className="hover:text-gray-200 transition-colors">Contact Support</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
