public with sharing class TestCookie {
    public TestCookie() {
        Cookie un = new Cookie('un', 'harry', null, 7200, false);
        ApexPages.currentPage().setCookies(new Cookie[] {un});

    }
}