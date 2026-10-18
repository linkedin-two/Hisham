import React from "react";
import Link from "next/link";

export default function CtaBand() {
  return (
    <section className="bg-[#144787] text-white">
      <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-7 items-center justify-between">
        <div className="flex-1 min-w-[300px] md:min-w-[440px] flex flex-col gap-3">
          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight font-bold">
            Ready to see a class in action?
          </h2>
          <p className="text-base sm:text-[17px] text-[#D6E3F6] leading-relaxed">
            Book a free demo and meet the teacher before you decide.
          </p>
        </div>

        <Link
          href="/contact"
          className="bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-base md:text-[17px] px-8 py-4 rounded-full inline-block transition-transform transform hover:-translate-y-0.5 shadow-md"
        >
          Book a free demo class
        </Link>
      </div>
    </section>
  );
}
