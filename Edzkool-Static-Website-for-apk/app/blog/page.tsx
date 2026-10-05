import React from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { BLOG_POSTS } from "@/data/blog-data";
import { ArrowRight } from "lucide-react";

export const metadata = {
  title: "Edzkool Coaching Blog",
  description: "Read the latest news, guides, and tips on IELTS preparation, coding, and academic excellence for grades 1-10.",
};

export default function BlogListingPage() {
  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <div className="bg-gradient-to-b from-[#F0F4FA] to-white py-12 md:py-16">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="text-center space-y-4 mb-12">
            <h1 className="text-4xl font-black text-gray-900">Edzkool Medical Blog</h1>
            <p className="text-lg text-gray-600 font-medium max-w-2xl mx-auto">
              Expert insights, destination guides, and exam preparation strategies for Indian medical students studying abroad.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {BLOG_POSTS.map((post) => (
              <div key={post.slug} className="bg-white rounded-3xl p-6 shadow-bright border border-gray-100 flex flex-col h-full hover:shadow-lg transition-shadow">
                <div className="mb-4">
                  <span className="text-[10px] font-black text-[#F58220] bg-[#F58220]/10 px-2.5 py-1 rounded-pill uppercase tracking-wider">
                    {post.category}
                  </span>
                </div>
                <h2 className="text-xl font-extrabold text-[#103C82] mb-3 leading-snug">
                  {post.title}
                </h2>
                <p className="text-sm text-gray-600 font-medium mb-6 flex-grow line-clamp-3">
                  {post.excerpt}
                </p>
                <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                  <span className="text-xs font-bold text-gray-500">{post.date}</span>
                  <Link href={`/blog/${post.slug}`} className="inline-flex items-center space-x-1 text-sm font-extrabold text-[#103C82] hover:text-[#F58220] transition-colors">
                    <span>Read More</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <Footer />
    </main>
  );
}
