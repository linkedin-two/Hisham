import React from "react";
import { notFound } from "next/navigation";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { CheckCircle2, Clock, Monitor, BookOpen } from "lucide-react";

interface ProgramPageProps {
  params: Promise<{ slug: string }> | { slug: string };
}

export async function generateStaticParams() {
  return EDZKOOL_DATA.programs.map((program) => ({
    slug: program.slug,
  }));
}

export async function generateMetadata({ params }: ProgramPageProps) {
  const resolvedParams = await params;
  const program = EDZKOOL_DATA.programs.find((p) => p.slug === resolvedParams.slug);
  if (!program) return {};

  return {
    title: `${program.name} | Edzkool Coaching`,
    description: program.description,
  };
}

export default async function ProgramPage({ params }: ProgramPageProps) {
  const resolvedParams = await params;
  const program = EDZKOOL_DATA.programs.find((p) => p.slug === resolvedParams.slug);

  if (!program) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      
      {/* Hero Section */}
      <section className="bg-[#103C82] text-white py-20 relative overflow-hidden">
        <div className="absolute inset-0 opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 flex flex-col md:flex-row items-center gap-10">
          <div className="md:w-1/2 space-y-6">
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-black leading-tight">
              {program.name}
            </h1>
            <p className="text-xl text-blue-100 font-medium max-w-lg">
              {program.description}
            </p>
            <div className="flex gap-4 pt-4">
              <span className="bg-white/10 px-4 py-2 rounded-full font-bold flex items-center gap-2">
                <Clock className="w-4 h-4 text-[#F58220]" /> {program.duration}
              </span>
              <span className="bg-white/10 px-4 py-2 rounded-full font-bold flex items-center gap-2">
                <Monitor className="w-4 h-4 text-[#F58220]" /> {program.mode}
              </span>
            </div>
          </div>
          <div className="md:w-1/2 w-full">
            <img 
              src={program.image} 
              alt={program.name} 
              className="rounded-3xl shadow-2xl border-4 border-white/10 transform rotate-2 hover:rotate-0 transition-transform duration-500"
            />
          </div>
        </div>
      </section>

      {/* Details Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-white rounded-3xl p-8 lg:p-12 shadow-sm border border-gray-100">
            <h2 className="text-3xl font-black text-gray-900 mb-8 flex items-center gap-3">
              <BookOpen className="w-8 h-8 text-[#F58220]" /> 
              What You Will Learn
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {program.features.map((feature, idx) => (
                <div key={idx} className="flex items-start gap-4 p-4 rounded-2xl bg-[#F0F4FA] border border-blue-100/50">
                  <CheckCircle2 className="w-6 h-6 text-[#103C82] shrink-0" />
                  <span className="font-bold text-gray-700">{feature}</span>
                </div>
              ))}
            </div>

            <div className="mt-12 text-center">
              <Link 
                href="/#download-apk" 
                className="inline-block bg-[#F58220] hover:bg-[#e07519] text-white px-10 py-4 rounded-full font-black text-lg transition-transform transform hover:scale-105 shadow-xl shadow-orange-500/20"
              >
                Enroll Now
              </Link>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
