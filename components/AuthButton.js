"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import AuthModal from "./AuthModal";
import { Button } from "@/components/ui/button";
import { LogIn, LogOut } from "lucide-react";

export default function AuthButton() {
  const supabase = createClient();
  const [user, setUser] = useState(null);
  const [showAuthModal, setShowAuthModal] = useState(false);

  useEffect(() => {
    // Get existing session on load
    supabase.auth.getUser().then(({ data }) => {
      setUser(data.user);
    });

    // Listen for auth changes (login / logout)
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (user) {
    return (
      <Button
        onClick={() => supabase.auth.signOut()}
        variant="ghost"
        size="sm"
        className="gap-2"
      >
        <LogOut className="w-4 h-4" />
        Sign Out
      </Button>
    );
  }

  return (
    <>
      <Button
        onClick={() => setShowAuthModal(true)}
        className="bg-orange-500 hover:bg-orange-600 gap-2"
      >
        <LogIn className="w-4 h-4" />
        Sign In
      </Button>

      <AuthModal
        isOpen={showAuthModal}
        onClose={() => setShowAuthModal(false)}
      />
    </>
  );
}
