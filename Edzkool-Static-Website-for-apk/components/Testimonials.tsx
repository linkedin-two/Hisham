import React from "react";
import { EDZKOOL_DATA, Testimonial } from "@/data/edzkool-data";
import { Star, Quote, CheckCircle2 } from "lucide-react";

export default function Testimonials() {
  return (
    <section id="reviews" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-block bg-yellow-100 text-yellow-900 font-extrabold text-xs px-4 py-1.5 rounded-pill uppercase tracking-widest mb-3">
            Real Stories, Real Doctors
          </div>
          <h2 className="text-3xl sm:text-4xl font-black text-gray-900 tracking-tight">
            What Our Students Say
          </h2>
          <p className="text-base text-gray-600 font-medium mt-3">
            Hear directly from students achieving their academic goals with Edzkool coaching.
          </p>
        </div>

        {/* Testimonials Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {EDZKOOL_DATA.testimonials.map((t: Testimonial, idx: number) => (
            <div
              key={idx}
              className="bg-white rounded-3xl p-8 border border-gray-100 shadow-bright hover:-translate-y-2 transition-all duration-300 flex flex-col justify-between relative"
            >
              <Quote className="w-10 h-10 text-purple-100 absolute top-6 right-6 pointer-events-none" />

              <div>
                {/* Star Rating */}
                <div className="flex items-center space-x-1 mb-4">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-4 h-4 fill-bright-yellow text-bright-yellow" />
                  ))}
                  <span className="text-xs font-black text-gray-800 ml-2">Verified Review</span>
                </div>

                <p className="text-sm text-gray-700 font-medium leading-relaxed mb-6 italic">
                  &ldquo;{t.review}&rdquo;
                </p>
              </div>

              {/* Student Footer Profile */}
              <div className="pt-4 border-t border-gray-100 flex items-center space-x-4">
                <img
                  src={t.image}
                  alt={t.name}
                  className="w-12 h-12 rounded-full object-cover border-2 border-bright-purple shadow-sm"
                />
                <div>
                  <div className="flex items-center space-x-1">
                    <span className="font-extrabold text-sm text-gray-900">{t.name}</span>
                    <CheckCircle2 className="w-4 h-4 text-bright-teal shrink-0" />
                  </div>
                  <span className="text-xs font-bold text-bright-purple block">
                    {t.exam} ({t.score})
                  </span>
                  <span className="text-[10px] text-gray-400 font-semibold">{''}</span>
                </div>
              </div>

            </div>
          ))}
        </div>

      </div>
    </section>
  );
}
