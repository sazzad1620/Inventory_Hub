import { useState } from 'react';
import Login from './components/Login';
import InventoryDashboard from './components/InventoryDashboard';
import AddProduct from './components/AddProduct';

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

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [language, setLanguage] = useState<'en' | 'bn'>('en');
  const [currentScreen, setCurrentScreen] = useState('inventory');
  const [editingProductId, setEditingProductId] = useState<number | null>(null);
  const [products, setProducts] = useState<Product[]>([
    { id: 1, name: 'Basmati Rice 5kg', buyingPrice: 280, price: 350, stock: 3, minStock: 5, createdAt: '2026-04-20T10:30:00', updatedAt: '2026-04-25T09:15:00' },
    { id: 2, name: 'Sugar 1kg', buyingPrice: 38, price: 50, stock: 15, minStock: 10, createdAt: '2026-04-21T14:20:00', updatedAt: '2026-04-24T16:45:00' },
    { id: 3, name: 'Sunflower Oil 1L', buyingPrice: 120, price: 155, stock: 2, minStock: 5, createdAt: '2026-04-22T11:00:00', updatedAt: '2026-04-25T08:30:00' },
    { id: 4, name: 'Wheat Flour 10kg', buyingPrice: 320, price: 400, stock: 8, minStock: 3, createdAt: '2026-04-19T09:15:00', updatedAt: '2026-04-23T12:00:00' },
    { id: 5, name: 'Tea Powder 500g', buyingPrice: 180, price: 225, stock: 12, minStock: 5, createdAt: '2026-04-23T15:30:00', updatedAt: '2026-04-25T07:20:00' },
    { id: 6, name: 'Salt 1kg', buyingPrice: 15, price: 22, stock: 20, minStock: 10, createdAt: '2026-04-18T13:45:00', updatedAt: '2026-04-24T10:10:00' },
  ]);

  const handleLogin = (selectedLanguage: 'en' | 'bn') => {
    setIsLoggedIn(true);
    setLanguage(selectedLanguage);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCurrentScreen('inventory');
    setEditingProductId(null);
  };

  const handleNavigate = (screen: string, productId?: number) => {
    setCurrentScreen(screen);
    if (productId !== undefined) {
      setEditingProductId(productId);
    } else {
      setEditingProductId(null);
    }
  };

  const handleAddProduct = (newProduct: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>) => {
    const now = new Date().toISOString();
    const product = {
      ...newProduct,
      id: Math.max(0, ...products.map((p) => p.id)) + 1,
      createdAt: now,
      updatedAt: now,
    };
    setProducts([...products, product]);
  };

  const handleUpdateProduct = (id: number, updatedProduct: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>) => {
    const now = new Date().toISOString();
    setProducts(products.map((p) => (p.id === id ? { ...updatedProduct, id, createdAt: p.createdAt, updatedAt: now } : p)));
  };

  const handleDeleteProduct = (id: number) => {
    setProducts(products.filter((p) => p.id !== id));
  };

  if (!isLoggedIn) {
    return <Login onLogin={handleLogin} />;
  }

  if (currentScreen === 'add' || currentScreen === 'edit') {
    const editProduct = editingProductId
      ? products.find((p) => p.id === editingProductId) || null
      : null;

    return (
      <AddProduct
        onNavigate={handleNavigate}
        onAddProduct={handleAddProduct}
        onUpdateProduct={handleUpdateProduct}
        onDeleteProduct={handleDeleteProduct}
        editProduct={editProduct}
        language={language}
      />
    );
  }

  return (
    <InventoryDashboard
      products={products}
      onNavigate={handleNavigate}
      onLogout={handleLogout}
      language={language}
      onLanguageChange={setLanguage}
    />
  );
}