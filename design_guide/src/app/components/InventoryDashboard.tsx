import { Package, Search, LogOut, Globe } from 'lucide-react';
import { useState } from 'react';

interface Product {
  id: number;
  name: string;
  price: number;
  stock: number;
  createdAt: string;
  updatedAt: string;
}

interface InventoryDashboardProps {
  products: Product[];
  onNavigate: (screen: string, productId?: number) => void;
  onLogout: () => void;
  language: 'en' | 'bn';
  onLanguageChange: (lang: 'en' | 'bn') => void;
}

const translations = {
  en: {
    inventory: 'Inventory',
    search: 'Search by name or ID...',
    addProduct: 'Add Product',
    lowStock: 'Low Stock',
    units: 'units',
    noProducts: 'No products found',
    logout: 'Logout',
    updated: 'Updated',
  },
  bn: {
    inventory: 'ইনভেন্টরি',
    search: 'নাম বা আইডি দিয়ে খুঁজুন...',
    addProduct: 'পণ্য যোগ করুন',
    lowStock: 'কম স্টক',
    units: 'ইউনিট',
    noProducts: 'কোন পণ্য পাওয়া যায়নি',
    logout: 'লগআউট',
    updated: 'আপডেট হয়েছে',
  },
};

export default function InventoryDashboard({
  products,
  onNavigate,
  onLogout,
  language,
  onLanguageChange,
}: InventoryDashboardProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const t = translations[language];

  const filteredProducts = products.filter((product) =>
    product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    product.id.toString().includes(searchQuery)
  );

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;

    return date.toLocaleDateString(language === 'bn' ? 'bn-BD' : 'en-US', {
      month: 'short',
      day: 'numeric',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a0a0a] via-[#121212] to-[#1a1a1a] text-white">
      <div className="sticky top-0 bg-[#121212]/95 backdrop-blur-xl border-b border-gray-800/50 px-4 py-3 z-10">
        <div className="flex items-center justify-between mb-3">
          <h1 className="text-2xl tracking-tight">{t.inventory}</h1>
          <div className="flex items-center gap-2">
            <button
              onClick={() => onLanguageChange(language === 'en' ? 'bn' : 'en')}
              className="p-2 hover:bg-gray-800/50 rounded-lg transition-colors"
              title="Change Language"
            >
              <Globe className="w-5 h-5 text-gray-400" />
            </button>
            <button
              onClick={onLogout}
              className="p-2 hover:bg-gray-800/50 rounded-lg transition-colors"
              title={t.logout}
            >
              <LogOut className="w-5 h-5 text-gray-400" />
            </button>
          </div>
        </div>

        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input
            type="text"
            placeholder={t.search}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-11 pr-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
          />
        </div>
      </div>

      <div className="p-4 pb-24 space-y-2">
        {filteredProducts.map((product) => (
          <button
            key={product.id}
            onClick={() => onNavigate('edit', product.id)}
            className="w-full bg-gradient-to-br from-[#1a1a1a] to-[#1e1e1e] border border-gray-800/50 rounded-xl p-4 hover:border-emerald-500/30 hover:shadow-lg hover:shadow-emerald-500/5 transition-all group"
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <div className="w-12 h-12 bg-gradient-to-br from-emerald-500/10 to-emerald-600/5 rounded-xl flex items-center justify-center group-hover:from-emerald-500/20 group-hover:to-emerald-600/10 transition-all shrink-0">
                  <Package className="w-6 h-6 text-emerald-500/70" />
                </div>
                <div className="text-left min-w-0 flex-1">
                  <div className="flex items-center gap-2 flex-wrap">
                    <h3 className="text-white group-hover:text-emerald-400 transition-colors truncate">
                      {product.name}
                    </h3>
                    {product.stock < 5 && (
                      <span className="px-2 py-0.5 bg-amber-500/20 text-amber-400 text-xs rounded-md border border-amber-500/30 shrink-0">
                        {t.lowStock}
                      </span>
                    )}
                  </div>
                  <p className="text-emerald-400 text-sm mt-0.5">
                    ₹{product.price.toFixed(2)}
                  </p>
                </div>
              </div>
              <div className="text-right shrink-0 ml-3">
                <div className="text-xl">{product.stock}</div>
                <div className="text-gray-500 text-xs">{t.units}</div>
              </div>
            </div>
            <div className="flex items-center justify-between text-xs text-gray-500 pt-2 border-t border-gray-800/50">
              <span>ID: #{product.id}</span>
              <span>{t.updated}: {formatDate(product.updatedAt)}</span>
            </div>
          </button>
        ))}

        {filteredProducts.length === 0 && (
          <div className="text-center py-16 text-gray-500">
            <Package className="w-16 h-16 mx-auto mb-4 opacity-20" />
            <p>{t.noProducts}</p>
          </div>
        )}
      </div>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-[#121212] via-[#121212] to-transparent pointer-events-none">
        <button
          onClick={() => onNavigate('add')}
          className="w-full py-4 bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-500 hover:to-emerald-600 text-white rounded-xl shadow-lg shadow-emerald-500/25 transition-all pointer-events-auto"
        >
          {t.addProduct}
        </button>
      </div>
    </div>
  );
}
