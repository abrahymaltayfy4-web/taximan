import type { Metadata } from "next";
import "./globals.css";
import { AuthProvider } from "@/lib/auth-context";
import ClientLayout from "@/components/layout/ClientLayout";

export const metadata: Metadata = {
  title: "Rahal Admin - لوحة التحكم",
  description: "لوحة تحكم نظام رحال للتاكسي",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className="bg-[#FAF8F5] text-gray-900 antialiased">
        <AuthProvider>
          <ClientLayout>{children}</ClientLayout>
        </AuthProvider>
      </body>
    </html>
  );
}
