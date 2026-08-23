import { Navigate, Route, Routes } from 'react-router-dom';
import AdminLayout from './layout/AdminLayout';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import BannersPage from './pages/BannersPage';
import ProductsPage from './pages/ProductsPage';
import CategoriesPage from './pages/CategoriesPage';
import HomeConfigPage from './pages/HomeConfigPage';
import ThemeActivitiesPage from './pages/ThemeActivitiesPage';
import OrdersPage from './pages/OrdersPage';
import CouponsPage from './pages/CouponsPage';
import FlashSalePage from './pages/FlashSalePage';
import CartMarqueePage from './pages/CartMarqueePage';
import SearchHotPage from './pages/SearchHotPage';
import ReviewsPage from './pages/ReviewsPage';
import LegacyActivityPage from './pages/LegacyActivityPage';

function RequireAuth({ children }: { children: React.ReactNode }) {
  const token = localStorage.getItem('shoo_admin_token');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/"
        element={
          <RequireAuth>
            <AdminLayout />
          </RequireAuth>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="home" element={<HomeConfigPage />} />
        <Route path="theme-activities" element={<ThemeActivitiesPage />} />
        <Route path="banners" element={<BannersPage />} />
        <Route path="products" element={<ProductsPage />} />
        <Route path="categories" element={<CategoriesPage />} />
        <Route path="orders" element={<OrdersPage />} />
        <Route path="coupons" element={<CouponsPage />} />
        <Route path="flash-sale" element={<FlashSalePage />} />
        <Route path="cart-marquee" element={<CartMarqueePage />} />
        <Route path="search-hot" element={<SearchHotPage />} />
        <Route path="reviews" element={<ReviewsPage />} />
        <Route path="legacy-activity" element={<LegacyActivityPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
