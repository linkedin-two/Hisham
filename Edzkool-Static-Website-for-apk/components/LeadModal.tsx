"use client";

import React, { useState } from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { X, CheckCircle, Stethoscope, Sparkles } from "lucide-react";

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function LeadModal({ isOpen, onClose }: ModalProps) {
  const [submitted, setSubmitted] = useState(false);
  const [selectedCountry, setSelectedCountry] = useState("Russia");

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => {
      setSubmitted(false);
      onClose();
    }, 2500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/60 backdrop-blur-sm animate-fade-in">
      <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl border border-gray-100 relative overflow-hidden">
        
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-700 bg-gray-100 p-2 rounded-full transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {submitted ? (
          <div className="py-12 text-center space-y-4">
            <div className="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto">
              <CheckCircle className="w-10 h-10" />
            </div>
            <h3 className="text-2xl font-black text-gray-900">Application Received!</h3>
            <p className="text-sm text-gray-600 font-medium max-w-xs mx-auto">
              Our Senior Medical Admission Counselor will reach out to you within 2 hours on WhatsApp.
            </p>
          </div>
        ) : (
          <div>
            <div className="flex items-center space-x-2 text-bright-purple font-extrabold text-xs bg-purple-100 px-3 py-1 rounded-pill w-fit mb-3">
              <Sparkles className="w-3.5 h-3.5" />
              <span>FREE 1-ON-1 COUNSELING</span>
            </div>

            <h3 className="text-2xl font-black text-gray-900 mb-1">
              Start Your Medical Journey
            </h3>
            <p className="text-xs text-gray-500 font-medium mb-6">
              Fill out your details to get free fee structure, eligibility audit, and NMC university list.
            </p>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-extrabold text-gray-700 uppercase tracking-wider mb-2">
                  Select Preferred Country:
                </label>
                <div className="flex flex-wrap gap-2">
                  {["Russia", "Georgia", "Kazakhstan", "Uzbekistan", "Egypt"].map((c) => (
                    <button
                      type="button"
                      key={c}
                      onClick={() => setSelectedCountry(c)}
                      className={`px-3 py-1.5 text-xs font-extrabold rounded-pill transition-all ${
                        selectedCountry === c
                          ? "bg-bright-purple text-white shadow-xs"
                          : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                      }`}
                    >
                      {c}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <input
                  type="text"
                  required
                  placeholder="Student's Name *"
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-bright-purple font-medium"
                />
              </div>

              <div>
                <input
                  type="tel"
                  required
                  placeholder="WhatsApp Mobile Number *"
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-bright-purple font-medium"
                />
              </div>

              <div>
                <input
                  type="email"
                  placeholder="Email Address"
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-bright-purple font-medium"
                />
              </div>

              <button
                type="submit"
                className="w-full bg-bright-purple hover:bg-bright-purple-dark text-white font-black py-4 rounded-pill text-sm transition-all shadow-lg hover:shadow-bright-purple/40"
              >
                Submit & Get Instant Consultation →
              </button>
            </form>
          </div>
        )}

      </div>
    </div>
  );
}
