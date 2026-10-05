import React from "react";
import { notFound } from "next/navigation";
import { BLOG_POSTS } from "@/data/blog-data";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { ArrowLeft, User, Calendar } from "lucide-react";

interface BlogPostProps {
  params: Promise<{ slug: string }> | { slug: string };
}

export async function generateStaticParams() {
  return BLOG_POSTS.map((post) => ({
    slug: post.slug,
  }));
}

export async function generateMetadata({ params }: BlogPostProps) {
  const resolvedParams = await params;
  const post = BLOG_POSTS.find((p) => p.slug === resolvedParams.slug);
  if (!post) return {};

  return {
    title: `${post.title} | Edzkool Blog`,
    description: post.excerpt,
  };
}

export default async function BlogPostPage({ params }: BlogPostProps) {
  const resolvedParams = await params;
  const post = BLOG_POSTS.find((p) => p.slug === resolvedParams.slug);

  if (!post) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <div className="bg-[#F0F4FA] py-12">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <Link
            href="/blog"
            className="inline-flex items-center space-x-2 text-[#103C82] font-extrabold text-sm hover:underline mb-8"
          >
            <ArrowLeft className="w-4 h-4 text-[#F58220]" />
            <span>Back to Blog</span>
          </Link>
          
          <div className="space-y-6">
            <span className="text-xs font-black text-[#F58220] bg-white px-3 py-1.5 rounded-pill shadow-xs uppercase tracking-wider">
              {post.category}
            </span>
            <h1 className="text-3xl sm:text-4xl md:text-5xl font-black text-gray-900 leading-tight">
              {post.title}
            </h1>
            <div className="flex items-center space-x-6 text-sm font-bold text-gray-500 pt-2">
              <div className="flex items-center space-x-2">
                <User className="w-4 h-4 text-[#103C82]" />
                <span>{post.author}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Calendar className="w-4 h-4 text-[#103C82]" />
                <span>{post.date}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="py-12">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="prose prose-lg prose-blue max-w-none font-medium text-gray-700">
            {post.content.split('\n').map((paragraph, index) => (
              <p key={index} className="mb-6 leading-relaxed">
                {paragraph}
              </p>
            ))}
          </div>
        </div>
      </div>
      <Footer />
    </main>
  );
}
