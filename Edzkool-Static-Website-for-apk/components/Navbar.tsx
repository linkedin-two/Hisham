"use client";

import React, { useState } from "react";
import Link from "next/link";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Menu, X, PhoneCall } from "lucide-react";

interface NavbarProps {
  onOpenModal?: () => void;
}

export default function Navbar({ onOpenModal }: NavbarProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleModalClick = () => {
    if (onOpenModal) {
      onOpenModal();
    } else {
      window.location.href = "/#download-apk";
    }
  };

  return (
    <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-gray-100 shadow-xs transition-all">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
        
        {/* Logo Image + Brand edzkool */}
        <Link href="/" className="flex items-center space-x-3 group">
          <img
            src="/logo.png"
            alt="Edzkool Logo"
            className="h-11 w-auto object-contain rounded-xl shadow-sm group-hover:scale-105 transition-transform"
          />
          <div className="flex flex-col">
            <div className="flex items-center space-x-1">
              <span className="font-black tracking-tight leading-none text-2xl">
                <span className="text-[#103C82]">edz</span>
                <span className="text-[#F58220]">k</span>
                <span className="text-[#103C82]">ool</span>
              </span>
              <span className="bg-[#F58220] text-white text-[10px] font-black uppercase px-2 py-0.5 rounded-pill shadow-xs ml-1">
                
              </span>
            </div>
            <span className="text-[11px] text-gray-500 font-semibold tracking-wide hidden sm:inline-block">
              1-ON-1 ONLINE COACHING CENTER
            </span>
          </div>
        </Link>

        {/* Links */}
        <div className="hidden lg:flex items-center space-x-6 font-bold text-gray-700 text-sm">
          <Link href="/#services" className="hover:text-[#103C82] transition-colors">
            Services
          </Link>
          <Link href="/#programs" className="hover:text-[#103C82] transition-colors">
            Programs
          </Link>
          <Link href="/programs/ielts" className="hover:text-[#103C82] transition-colors">
            IELTS Prep
          </Link>
          <Link href="/programs/coding" className="hover:text-[#103C82] transition-colors">
            Coding Classes
          </Link>
          <Link href="/blog" className="hover:text-[#103C82] transition-colors">
            Blog
          </Link>
          <Link href="/#reviews" className="hover:text-[#103C82] transition-colors">
            Reviews
          </Link>
        </div>

        {/* CTA */}
        <div className="hidden sm:flex items-center space-x-4">
          <a
            href={`tel:${EDZKOOL_DATA.company.phone}`}
            className="flex items-center space-x-2 text-[#103C82] font-extrabold text-sm hover:underline"
          >
            <PhoneCall className="w-4 h-4 text-[#F58220]" />
            <span className="hidden xl:inline">{EDZKOOL_DATA.company.phone}</span>
          </a>
          <button
            onClick={handleModalClick}
            className="bg-[#103C82] hover:bg-[#0B2A5D] text-white px-6 py-2.5 rounded-pill font-black text-sm transition-all transform hover:-translate-y-0.5 shadow-md border-b-2 border-[#F58220]"
          >
            Book Free Counseling
          </button>
        </div>

        {/* Mobile Toggle */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="lg:hidden p-2 text-gray-700 rounded-lg hover:bg-gray-100"
          aria-label="Toggle Menu"
        >
          {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="lg:hidden bg-white border-b border-gray-200 px-4 pt-2 pb-6 space-y-4 font-bold text-gray-800">
          <Link
            href="/#services"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 hover:text-[#103C82]"
          >
            Services
          </Link>
          <Link
            href="/#programs"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 hover:text-[#103C82]"
          >
            Programs
          </Link>
          <Link
            href="/programs/ielts"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 hover:text-[#103C82]"
          >
            IELTS Prep
          </Link>
          <Link
            href="/programs/coding"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 hover:text-[#103C82]"
          >
            Coding Classes
          </Link>
          <Link
            href="/blog"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 hover:text-[#103C82]"
          >
            Blog
          </Link>
          <button
            onClick={() => {
              setMobileMenuOpen(false);
              handleModalClick();
            }}
            className="w-full bg-[#103C82] text-white py-3 rounded-pill font-extrabold text-center shadow-md border-b-2 border-[#F58220]"
          >
            Book Free Counseling
          </button>
        </div>
      )}
    </nav>
  );
}
