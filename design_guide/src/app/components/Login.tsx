import { useState } from 'react';
import { Globe } from 'lucide-react';

const translations = {
  en: {
    title: 'GroceryHub',
    subtitle: 'Sign in to your account',
    email: 'Email',
    emailPlaceholder: 'owner@grocery.com',
    password: 'Password',
    passwordPlaceholder: '••••••••',
    signIn: 'Sign In',
  },
  bn: {
    title: 'গ্রোসারিহাব',
    subtitle: 'আপনার অ্যাকাউন্টে সাইন ইন করুন',
    email: 'ইমেইল',
    emailPlaceholder: 'owner@grocery.com',
    password: 'পাসওয়ার্ড',
    passwordPlaceholder: '••••••••',
    signIn: 'সাইন ইন',
  },
};

interface LoginProps {
  onLogin: (language: 'en' | 'bn') => void;
}

export default function Login({ onLogin }: LoginProps) {
  const [language, setLanguage] = useState<'en' | 'bn'>('en');
  const t = translations[language];

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a0a0a] via-[#121212] to-[#1a1a1a] flex items-center justify-center p-6">
      <div className="w-full max-w-sm space-y-8">
        <div className="text-center space-y-3">
          <div className="inline-block p-4 bg-gradient-to-br from-emerald-500/10 to-emerald-600/5 rounded-2xl mb-2">
            <div className="w-12 h-12 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-xl flex items-center justify-center text-2xl">
              🏪
            </div>
          </div>
          <h1 className="text-white text-3xl tracking-tight">{t.title}</h1>
          <p className="text-gray-400">{t.subtitle}</p>
        </div>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            onLogin(language);
          }}
          className="space-y-4"
        >
          <div className="space-y-2">
            <label htmlFor="email" className="block text-gray-300 text-sm">
              {t.email}
            </label>
            <input
              id="email"
              type="email"
              placeholder={t.emailPlaceholder}
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
              defaultValue="demo@grocery.com"
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="password" className="block text-gray-300 text-sm">
              {t.password}
            </label>
            <input
              id="password"
              type="password"
              placeholder={t.passwordPlaceholder}
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
              defaultValue="demo123"
            />
          </div>

          <button
            type="submit"
            className="w-full py-4 bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-500 hover:to-emerald-600 text-white rounded-xl shadow-lg shadow-emerald-500/25 transition-all mt-6"
          >
            {t.signIn}
          </button>
        </form>

        <div className="flex items-center justify-center gap-2 pt-4">
          <Globe className="w-4 h-4 text-gray-500" />
          <button
            onClick={() => setLanguage('en')}
            className={`px-3 py-1 rounded-lg text-sm transition-colors ${
              language === 'en'
                ? 'bg-emerald-500/20 text-emerald-400'
                : 'text-gray-400 hover:text-white'
            }`}
          >
            English
          </button>
          <button
            onClick={() => setLanguage('bn')}
            className={`px-3 py-1 rounded-lg text-sm transition-colors ${
              language === 'bn'
                ? 'bg-emerald-500/20 text-emerald-400'
                : 'text-gray-400 hover:text-white'
            }`}
          >
            বাংলা
          </button>
        </div>
      </div>
    </div>
  );
}
