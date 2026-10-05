import { MetadataRoute } from "next";
import { BLOG_POSTS } from "../data/blog-data";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://edzkool.com";

  const programs = ["ielts", "grades-1-10", "coding", "english"];

  const programUrls = programs.map((c) => ({
    url: `${baseUrl}/programs/${c}`,
    lastModified: new Date(),
    changeFrequency: "weekly" as const,
    priority: 0.8,
  }));

  const blogUrls = BLOG_POSTS.map((post) => ({
    url: `${baseUrl}/blog/${post.slug}`,
    lastModified: new Date(),
    changeFrequency: "monthly" as const,
    priority: 0.7,
  }));

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: "daily",
      priority: 1.0,
    },
    {
      url: `${baseUrl}/blog`,
      lastModified: new Date(),
      changeFrequency: "daily",
      priority: 0.8,
    },
    ...programUrls,
    ...blogUrls,
  ];
}
