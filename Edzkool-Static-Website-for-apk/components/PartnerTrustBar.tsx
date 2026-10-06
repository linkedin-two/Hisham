import React from "react";
import { ShieldCheck, Award, CheckCircle2 } from "lucide-react";

export default function PartnerTrustBar() {
  return (
    <section className="bg-white py-10 border-b border-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="text-center mb-6">
          <span className="text-xs font-black uppercase tracking-widest text-[#103C82] bg-[#EBF2FD] px-4 py-1 rounded-pill">
            Recognized & Authorized Admissions Partner
          </span>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-8 md:gap-14 opacity-90">
          
          {/* Partner 1 */}
          <div className="flex items-center space-x-3 bg-gray-50 px-5 py-3 rounded-2xl border border-gray-200 hover:border-[#103C82] transition-colors">
            <img src="/Hisham/allindiablooddonorsassociation.webp" alt="Partner Logo" className="h-10 w-auto object-contain" />
            <div className="text-left">
              <span className="font-extrabold text-xs text-gray-900 block">All India Donors Assoc.</span>
              <span className="text-[10px] text-gray-500 font-semibold">Official Health & Medical Partner</span>
            </div>
          </div>

          {/* Partner 2 */}
          <div className="flex items-center space-x-3 bg-gray-50 px-5 py-3 rounded-2xl border border-gray-200 hover:border-[#F58220] transition-colors">
            <img src="/Hisham/ashik.webp" alt="Consultancy Partner" className="h-10 w-auto object-contain" />
            <div className="text-left">
              <span className="font-extrabold text-xs text-gray-900 block">Ashik Educational Consultancy</span>
              <span className="text-[10px] text-[#F58220] font-bold">Authorized Placement Hub</span>
            </div>
          </div>

          {/* Partner 3: SVG Icon Badge 1 */}
          <div className="flex items-center space-x-3 bg-gray-50 px-5 py-3 rounded-2xl border border-gray-200">
            <img src="/Hisham/image (1).svg" alt="NMC Certified" className="h-8 w-8 object-contain" />
            <div className="text-left">
              <span className="font-extrabold text-xs text-gray-900 block">NMC & WHO Compliant</span>
              <span className="text-[10px] text-emerald-600 font-bold">100% English Medium</span>
            </div>
          </div>

          {/* Partner 4: SVG Icon Badge 2 */}
          <div className="flex items-center space-x-3 bg-gray-50 px-5 py-3 rounded-2xl border border-gray-200">
            <img src="/Hisham/image (2).svg" alt="Visa Clearance" className="h-8 w-8 object-contain" />
            <div className="text-left">
              <span className="font-extrabold text-xs text-gray-900 block">MEA & HRD Apostille</span>
              <span className="text-[10px] text-[#103C82] font-bold">99.8% Visa Approval</span>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
