import React from "react";
import { EDZKOOL_DATA, Testimonial } from "@/data/edzkool-data";
import { Star, Quote, CheckCircle2 } from "lucide-react";

export default function Testimonials() {
  const reviews = [
    {
      name: "Amina Shaik",
      exam: "IELTS Academic",
      score: "Band 7.5",
      review: "The personalized attention and daily doubt clearance helped me score 7.5 on my first IELTS attempt. The mentor's feedback on writing was a total game-changer!",
      image: "/18.png",
    },
    {
      name: "Rahul Verma",
      exam: "MBBS Russia",
      score: "PSMU Batch '24",
      review: "Securing admission to Perm State Medical University seemed daunting until Edzkool handled my entire documentation, visa apostille, and hostel placement seamlessly.",
      image: "/20.png",
    },
    {
      name: "Sneha Patel",
      exam: "Grade 10 CBSE",
      score: "96.4% Aggregate",
      review: "The 1-on-1 tutoring transformed my approach to math and science. Concepts that took weeks in school were mastered in just a few focused sessions with my tutor.",
      image: "/21.png",
    },
  ];

  return (
    <section id="testimonials" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center max-w-3xl mx-auto mb-14">
          <div className="inline-block bg-[#FEF6E9] text-[#F58220] font-bold text-xs px-3.5 py-1 rounded-full uppercase tracking-wider mb-2.5 border border-[#F58220]/20">
            Real Experiences
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-[#0B254E] tracking-tight">
            What Our Students Say
          </h2>
          <p className="text-sm sm:text-base text-gray-500 font-normal mt-2.5">
            Real stories from students and parents achieving success through our personalized tutoring.
          </p>
        </div>

        {/* Testimonials Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {reviews.map((t, idx) => (
            <div
              key={idx}
              className="bg-white rounded-2xl p-6 sm:p-7 border border-gray-100 shadow-xs hover:shadow-md hover:-translate-y-1 transition-all duration-300 flex flex-col justify-between relative"
            >
              <Quote className="w-8 h-8 text-blue-50 absolute top-5 right-5 pointer-events-none" />

              <div>
                {/* Star Rating */}
                <div className="flex items-center space-x-1 mb-4">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-4 h-4 fill-amber-400 text-amber-400" />
                  ))}
                  <span className="text-[11px] font-semibold text-gray-400 ml-1.5">Verified Student</span>
                </div>

                <p className="text-sm text-gray-600 font-normal leading-relaxed mb-6 italic">
                  &ldquo;{t.review}&rdquo;
                </p>
              </div>

              {/* Student Footer Profile */}
              <div className="pt-4 border-t border-gray-100 flex items-center space-x-3.5">
                <img
                  src={t.image}
                  alt={t.name}
                  className="w-11 h-11 rounded-full object-cover border border-gray-200 shadow-2xs"
                />
                <div>
                  <div className="flex items-center space-x-1.5">
                    <span className="font-bold text-sm text-gray-900">{t.name}</span>
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
                  </div>
                  <span className="text-xs font-semibold text-[#103C82] block">
                    {t.exam} • {t.score}
                  </span>
                </div>
              </div>

            </div>
          ))}
        </div>

      </div>
    </section>
  );
}
