const routes = [{
    path: '/',
    component: (resolve) => require(['./views/Home.vue'], resolve)
    },
    {path: '/selectbook',
    component: (resolve) => require(['./views/SelectBook.vue'], resolve)
    },
    {path: '/classselectbook',
    component: (resolve) => require(['./views/ClassSelectBook.vue'], resolve)
    },

    {
    path: '/information',
    component: (resolve) => require(['./views/Information.vue'], resolve)
    },

    {
    path: '/teacher',
    component: (resolve) => require(['./views/TeacherHome.vue'], resolve)
    },

    {
    path: '/JCK',
    component: (resolve) => require(['./views/ConfirmList.vue'], resolve)
    }
];
export default routes;