"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";

export default function Navbar() {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navLinks = [
    { name: "Home", href: "/" },
    { name: "Programs", href: "/programs" },
    { name: "Certifications", href: "/certifications" },
    { name: "About", href: "/about" },
    { name: "Contact", href: "/contact" },
  ];

  const isActive = (href: string) => {
    if (href === "/") return pathname === "/";
    return pathname.startsWith(href);
  };

  return (
    <>
      {/* 1. Top Announcement Bar */}
      <div className="bg-[#0B2A5B] text-white px-6 py-2.5 flex flex-wrap gap-x-5 gap-y-2 justify-center items-center text-sm font-medium z-50">
        <span>Admissions open for Grades 1 to 12</span>
        <Link
          href="/contact"
          className="text-[#FFB84D] font-bold hover:text-white transition-colors"
        >
          Book a free demo class →
        </Link>
      </div>

      {/* 2. Main Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-[#E3EAF4] shadow-xs">
        <div className="max-w-[1200px] mx-auto px-6 py-3.5 flex items-center justify-between gap-6">
          {/* Logo */}
          <Link href="/" aria-label="EDZKOOL home" className="flex items-center">
            <img
              src="/assets/17e886f9-9be4-4119-a22b-a34ae37ae216.png"
              alt="EDZKOOL"
              className="h-11 w-auto object-contain block"
            />
          </Link>

          {/* Desktop Navigation */}
          <nav aria-label="Main" className="hidden md:flex items-center gap-7 text-[15px] font-semibold">
            {navLinks.map((link) => {
              const active = isActive(link.href);
              return (
                <Link
                  key={link.name}
                  href={link.href}
                  className={`pb-1 transition-all ${
                    active
                      ? "text-[#144787] border-b-[3px] border-[#FD9202]"
                      : "text-[#1B2A44] hover:text-[#144787]"
                  }`}
                >
                  {link.name}
                </Link>
              );
            })}
          </nav>

          {/* Desktop CTA */}
          <div className="hidden md:block">
            <Link
              href="/contact"
              className="bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-[15px] px-6 py-3 rounded-full inline-block transition-transform transform hover:-translate-y-0.5 shadow-sm"
            >
              Book free demo
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 text-[#0B2A5B] rounded-lg hover:bg-gray-100"
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile Dropdown Drawer */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-white border-t border-[#E3EAF4] px-6 py-5 space-y-4 shadow-lg">
            {navLinks.map((link) => {
              const active = isActive(link.href);
              return (
                <Link
                  key={link.name}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`block py-1 text-base font-semibold ${
                    active ? "text-[#144787] font-bold" : "text-[#1B2A44]"
                  }`}
                >
                  {link.name}
                </Link>
              );
            })}
            <div className="pt-2">
              <Link
                href="/contact"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center bg-[#FD9202] text-[#0B2A5B] font-bold text-base px-6 py-3 rounded-full block shadow-sm"
              >
                Book free demo
              </Link>
            </div>
          </div>
        )}
      </header>
    </>
  );
}
