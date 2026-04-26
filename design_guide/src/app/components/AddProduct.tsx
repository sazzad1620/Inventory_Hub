import { ArrowLeft, Trash2 } from 'lucide-react';
import { useState, useEffect } from 'react';

interface Product {
  id: number;
  name: string;
  buyingPrice: number;
  price: number;
  stock: number;
  minStock: number;
  createdAt: string;
  updatedAt: string;
}

interface AddProductProps {
  onNavigate: (screen: string) => void;
  onAddProduct: (product: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>) => void;
  onUpdateProduct?: (id: number, product: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>) => void;
  onDeleteProduct?: (id: number) => void;
  editProduct?: Product | null;
  language: 'en' | 'bn';
}

const translations = {
  en: {
    addProduct: 'Add Product',
    editProduct: 'Edit Product',
    productName: 'Product Name',
    productNamePlaceholder: 'e.g., Basmati Rice 1kg',
    buyingPrice: 'Buying Price (₹)',
    sellingPrice: 'Selling Price (₹)',
    currentStock: 'Current Stock',
    stockLevel: 'Stock Level',
    save: 'Save Changes',
    add: 'Add Product',
    delete: 'Delete Product',
    created: 'Created',
    updated: 'Updated',
  },
  bn: {
    addProduct: 'পণ্য যোগ করুন',
    editProduct: 'পণ্য সম্পাদনা করুন',
    productName: 'পণ্যের নাম',
    productNamePlaceholder: 'যেমন, বাসমতি চাল ১ কেজি',
    buyingPrice: 'ক্রয় মূল্য (₹)',
    sellingPrice: 'বিক্রয় মূল্য (₹)',
    currentStock: 'বর্তমান স্টক',
    stockLevel: 'স্টক লেভেল',
    save: 'পরিবর্তন সংরক্ষণ করুন',
    add: 'পণ্য যোগ করুন',
    delete: 'পণ্য মুছুন',
    created: 'তৈরি হয়েছে',
    updated: 'আপডেট হয়েছে',
  },
};

export default function AddProduct({
  onNavigate,
  onAddProduct,
  onUpdateProduct,
  onDeleteProduct,
  editProduct,
  language,
}: AddProductProps) {
  const [name, setName] = useState('');
  const [buyingPrice, setBuyingPrice] = useState('');
  const [sellingPrice, setSellingPrice] = useState('');
  const [stock, setStock] = useState('');

  const t = translations[language];
  const isEditMode = !!editProduct;

  useEffect(() => {
    if (editProduct) {
      setName(editProduct.name);
      setBuyingPrice(editProduct.buyingPrice.toString());
      setSellingPrice(editProduct.price.toString());
      setStock(editProduct.stock.toString());
    }
  }, [editProduct]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const productData = {
      name,
      buyingPrice: parseFloat(buyingPrice),
      price: parseFloat(sellingPrice),
      stock: parseInt(stock),
      minStock: isEditMode && editProduct ? editProduct.minStock : 5,
    };

    if (isEditMode && editProduct && onUpdateProduct) {
      onUpdateProduct(editProduct.id, productData);
    } else {
      onAddProduct(productData);
    }

    onNavigate('inventory');
  };

  const handleDelete = () => {
    if (editProduct && onDeleteProduct) {
      const confirmMessage =
        language === 'bn'
          ? 'আপনি কি নিশ্চিত যে আপনি এই পণ্যটি মুছে ফেলতে চান?'
          : 'Are you sure you want to delete this product?';
      if (confirm(confirmMessage)) {
        onDeleteProduct(editProduct.id);
        onNavigate('inventory');
      }
    }
  };

  const formatDateTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleString(language === 'bn' ? 'bn-BD' : 'en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a0a0a] via-[#121212] to-[#1a1a1a] text-white">
      <div className="sticky top-0 bg-[#121212]/95 backdrop-blur-xl border-b border-gray-800/50 px-4 py-4 z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => onNavigate('inventory')}
              className="p-2 hover:bg-gray-800/50 rounded-lg transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <h1 className="text-xl">
              {isEditMode ? t.editProduct : t.addProduct}
            </h1>
          </div>
          {isEditMode && (
            <button
              onClick={handleDelete}
              className="p-2 hover:bg-red-500/10 text-red-400 rounded-lg transition-colors"
            >
              <Trash2 className="w-5 h-5" />
            </button>
          )}
        </div>
      </div>

      <form onSubmit={handleSubmit} className="p-4 space-y-5 pb-24">
        {isEditMode && editProduct && (
          <div className="bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl p-4 space-y-2">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-400">Product ID:</span>
              <span className="text-emerald-400 font-mono">#{editProduct.id}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-400">{t.created}:</span>
              <span className="text-gray-300">{formatDateTime(editProduct.createdAt)}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-400">{t.updated}:</span>
              <span className="text-gray-300">{formatDateTime(editProduct.updatedAt)}</span>
            </div>
          </div>
        )}

        <div className="space-y-2">
          <label htmlFor="name" className="block text-gray-300 text-sm">
            {t.productName}
          </label>
          <input
            id="name"
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder={t.productNamePlaceholder}
            className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label htmlFor="buying" className="block text-gray-300 text-sm">
              {t.buyingPrice}
            </label>
            <input
              id="buying"
              type="number"
              step="0.01"
              required
              value={buyingPrice}
              onChange={(e) => setBuyingPrice(e.target.value)}
              placeholder="0.00"
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="selling" className="block text-gray-300 text-sm">
              {t.sellingPrice}
            </label>
            <input
              id="selling"
              type="number"
              step="0.01"
              required
              value={sellingPrice}
              onChange={(e) => setSellingPrice(e.target.value)}
              placeholder="0.00"
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
            />
          </div>
        </div>

        {isEditMode ? (
          <div className="space-y-2">
            <label htmlFor="stock" className="block text-gray-300 text-sm">
              {t.currentStock}
            </label>
            <input
              id="stock"
              type="number"
              required
              value={stock}
              onChange={(e) => setStock(e.target.value)}
              placeholder="0"
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
            />
          </div>
        ) : (
          <div className="space-y-2">
            <label htmlFor="stock" className="block text-gray-300 text-sm">
              {t.stockLevel}
            </label>
            <input
              id="stock"
              type="number"
              required
              value={stock}
              onChange={(e) => setStock(e.target.value)}
              placeholder="0"
              className="w-full px-4 py-3 bg-[#1a1a1a]/50 border border-gray-800/50 rounded-xl text-white placeholder:text-gray-500 focus:outline-none focus:border-emerald-500/50 focus:bg-[#1a1a1a] transition-all"
            />
          </div>
        )}

        <div className="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-[#121212] via-[#121212] to-transparent">
          <button
            type="submit"
            className="w-full py-4 bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-500 hover:to-emerald-600 text-white rounded-xl shadow-lg shadow-emerald-500/25 transition-all"
          >
            {isEditMode ? t.save : t.add}
          </button>
        </div>
      </form>
    </div>
  );
}
