<template>
<div>
  <b-navbar type="dark" variant="dark" toggleable>
    <b-navbar-toggle target="nav_dropdown_collapse"></b-navbar-toggle>
    <b-collapse is-nav id="nav_dropdown_collapse">
      <b-navbar-nav>
        <b-nav-item href="/"><b>信息化教材科管理系统</b></b-nav-item>
        <b-nav-item href="/selectbook">个人选书</b-nav-item>
        <b-nav-item href="/classselectbook">班级选书</b-nav-item>
        <b-nav-item href="/information">完善信息</b-nav-item>
        <b-nav-item href="/">信息交流</b-nav-item>
        <b-nav-item href="/">排队实时</b-nav-item>
        <b-nav-item href="/teacher">教师入口</b-nav-item>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</div>
</template>
<script>
  export default{
    data(){}
  }
</script>